require "csv"
require Rails.root.join("db", "seeds", "data_paths").to_s
require Rails.root.join("db", "seeds", "ballot_line_seeder").to_s

module Seeds
  # Converts one state's sourced 2026 ballot rows into micharisma-seeds/v1 manifests for the
  # Ascent catalog, and reports the judgments conversion cannot settle on its own.
  #
  # Reads   races/2026/<state>/{federal,state}/*.yml, races/2026/<state>/conflicts.csv,
  #         conversion/2026/<state>/parties.yml, and us_states.yml.
  # Writes  manifests/foundation.yml, manifests/2026/<state>/*.yml, and
  #         conversion/2026/<state>/{usernames.yml,name_spellings.yml,judgments.md}.
  #
  # Usernames already recorded in usernames.yml are reused, so a username never changes once issued.
  class BallotManifestConverter
    class Error < StandardError; end

    YEAR = 2026
    DISTRICT_TOKENS = {
      "Congressional District" => [ "CONGRESS", "CD", "congress" ],
      "State Senate District" => [ "SENATE", "SD", "state_senate" ],
      "Assembly District" => [ "ASSEMBLY", "AD", "assembly" ]
    }.freeze
    PILOT_STATEWIDE_OFFICES = [ "Governor", "Lt. Governor", "Lieutenant Governor", "Comptroller", "Attorney General" ].freeze
    PILOT_DISTRICT_OFFICES = [ "Representative in Congress", "State Senator", "Member of Assembly" ].freeze
    PILOT_CONTESTS_PER_OFFICE = 4
    CERTIFICATION_STATUSES = [ [ /tentative|subject to change/i, "tentative" ], [ /unofficial/i, "unofficial" ], [ /certified/i, "certified" ] ].freeze
    UNMAPPED_FIELDS = %w[incumbent fec_candidate_id county jurisdiction notes cross_check_url].freeze

    attr_reader :summary

    def initialize(state_dir:, selection: :pilot, root: SeedDataPaths.primary_root)
      @state_dir, @selection, @root = state_dir, selection, Pathname.new(root)
    end

    def call
      load_inputs
      contests = selected_contests
      @issued = {}
      race_groups = contests.map { |(office, district), rows| contest_manifest(office, district, rows) }

      write_manifests(race_groups)
      write_reports(contests)
      @summary = {
        contests: contests.size,
        candidacies: race_groups.sum { |group| group[:candidacies] },
        off_ballot: @off_ballot.size,
        usernames_issued: @issued.size,
        files: written_paths.map { |path| path.relative_path_from(@root).to_s }
      }
    end

    private

    attr_reader :written_paths

    def load_inputs
      paths = Dir.glob(@root.join("races", YEAR.to_s, @state_dir, "{federal,state}", "*.yml").to_s).sort
      raise Error, "No federal or state ballot rows for #{@state_dir}" if paths.empty?

      @rows = paths.flat_map { |path| BallotLineSeeder.rows_from(path) }
      @state_code = @rows.first.fetch("state")
      @state_name = state_names.fetch(@state_code)
      @state_path = "USA-#{@state_code}"
      conflicts_path = @root.join("races", YEAR.to_s, @state_dir, "conflicts.csv")
      @conflicts = conflicts_path.exist? ? CSV.read(conflicts_path, headers: true).map(&:to_h) : []
      parties = YAML.load_file(conversion_dir.join("parties.yml"))
      @qualified = parties.fetch("qualified").to_h { |party| [ party.fetch("label"), party.fetch("code") ] }
      @other_label_kind = parties.fetch("other_labels", "unclassified")
      @usernames = (path = conversion_dir.join("usernames.yml")).exist? ? YAML.load_file(path) : {}
      @off_ballot = []
      @designations = Set.new
      @certifications = Hash.new { |hash, key| hash[key] = Set.new }
      @written_paths = []
    end

    def state_names
      YAML.load_file(@root.join("us_states.yml")).fetch("states").to_h { |state| [ state.fetch("code"), state.fetch("name") ] }
    end

    def conversion_dir
      @root.join("conversion", YEAR.to_s, @state_dir)
    end

    def manifest_dir
      @root.join("manifests", YEAR.to_s, @state_dir)
    end

    # The pilot covers statewide contests, the most contested districts for each legislative and
    # congressional office, and every contest in those offices with a logged source conflict.
    def selected_contests
      contests = @rows.group_by { |row| [ row.fetch("office"), row.fetch("district") ] }
      return contests if @selection == :all

      conflicted = @conflicts.map { |conflict| [ conflict["office"], conflict["district"].to_s ] }
      chosen = contests.keys.select { |office, district| district.empty? && PILOT_STATEWIDE_OFFICES.include?(office) }
      PILOT_DISTRICT_OFFICES.each do |office|
        ranked = contests.select { |(contest_office, _), _| contest_office == office }
                         .sort_by { |(_, district), rows| [ -rows.map { |row| row["candidate_name"] }.uniq.size, -rows.size, district.to_i ] }
        chosen += ranked.first(PILOT_CONTESTS_PER_OFFICE).map(&:first)
        chosen += ranked.map(&:first).select { |key| conflicted.include?(key) }
      end
      contests.slice(*chosen.uniq)
    end

    def contest_manifest(office_title, district, rows)
      position_title, district_kind = BallotLineSeeder::STATE_LEVEL_OFFICES.fetch(office_title) do
        raise Error, "No position mapping for #{@state_code} office #{office_title.inspect}"
      end
      place = place_for(district, district_kind)
      position_token = token(position_title)
      office_path = district.empty? ? "#{@state_path}-#{position_token}" : place[:path]
      seat = district.empty? ? position_token.downcase : place[:seat_code].downcase
      contest_key = "#{YEAR}_#{special?(rows) ? "SPECIAL" : "GENERAL"}"
      election_code = "ELECTION-#{place[:path]}-#{contest_key}"
      race_code = "RACE-#{office_path}-#{contest_key}"

      records = [
        record("Office", "OFFICE-#{office_path}", { "seat_code" => place[:seat_code], "is_active" => true }.compact,
               "position" => "POSITION-#{position_token}", "jurisdiction" => place[:code]),
        record("Race", race_code, { "status" => "upcoming", "certification_status" => certification(rows), "description" => BallotLineSeeder.race_description(rows) }.compact,
               "election" => election_code, "office" => "OFFICE-#{office_path}")
      ]
      candidacies = rows.group_by { |row| row.fetch("candidate_name") }.map do |name, candidate_rows|
        candidate_records(name, candidate_rows, office_title, district, seat, office_path, contest_key, race_code, "active")
      end
      off_ballot_names(office_title, district, rows).each do |name|
        candidacies << candidate_records(name, [], office_title, district, seat, office_path, contest_key, race_code, "off_ballot")
      end

      {
        file: district.empty? ? "statewide" : DISTRICT_TOKENS.fetch(district_kind).last,
        district: place[:district],
        election: election_record(place, election_code, rows),
        records: records + candidacies.flatten,
        candidacies: candidacies.size,
        position: [ position_token, position_title ]
      }
    end

    def candidate_records(name, rows, office_title, district, seat, office_path, contest_key, race_code, participation)
      parts = BallotLineSeeder.name_parts(name)
      username = username_for("#{office_title}|#{district}|#{name}", parts, seat)
      person = record("Person", "PERSON-#{username.upcase}",
                      { "username" => username, "username_status" => "provisional" }.merge(parts.transform_keys(&:to_s).compact))
      lines = rows.map { |row| row.fetch("party") }.compact_blank.uniq.map { |label| ballot_line(label) }
      candidacy_attributes = { "status" => "active", "participation" => participation }
      candidacy_attributes["ballot_lines"] = lines if lines.any?
      candidacy = record("Candidacy", "CANDIDACY-#{office_path}-#{contest_key}-#{username.upcase}", candidacy_attributes,
                         "race" => race_code, "person" => person["code"])
      [ person, candidacy ]
    end

    def ballot_line(label)
      if (party_code = @qualified[label])
        { "label" => label, "kind" => "party", "party" => "PARTY-#{@state_path}-#{party_code}" }
      elsif (kind = BallotLineSeeder::LABEL_KINDS[label])
        { "label" => label, "kind" => kind }
      else
        @designations << label if @other_label_kind == "designation"
        { "label" => label, "kind" => @other_label_kind }
      end
    end

    # Sources disagreeing on whether a person belongs in the contest: include them, off the ballot.
    def off_ballot_names(office_title, district, rows)
      printed = rows.map { |row| row["candidate_name"] }
      @conflicts.select { |conflict| conflict["field"] == "presence" && conflict["office"] == office_title && conflict["district"].to_s == district && conflict["value_a"] == "not listed" }
                .reject { |conflict| printed.include?(conflict["candidate_name"]) }
                .each { |conflict| @off_ballot << conflict }
                .map { |conflict| conflict["candidate_name"] }
                .uniq
    end

    def place_for(district, district_kind)
      return { type: "State", code: "STATE-#{@state_path}", path: @state_path } if district.empty?

      chamber, prefix, = DISTRICT_TOKENS.fetch(district_kind) { raise Error, "No district tokens for #{district_kind}" }
      raise Error, "Unexpected #{district_kind} label #{district.inspect}" unless district.match?(/\A\d+\z/)

      path = "#{@state_path}-#{chamber}-#{prefix}_#{district}"
      {
        type: "District", code: "DISTRICT-#{path}", path: path, seat_code: "#{prefix}_#{district}",
        district: record("District", "DISTRICT-#{path}", { "name" => "#{@state_name} #{district_kind} #{district}", "kind" => district_kind.downcase })
      }
    end

    def election_record(place, code, rows)
      name = place[:district] ? place[:district]["attributes"]["name"] : @state_name
      date = rows.first.fetch("election_date")
      record("Election", code,
             { "name" => "#{name} #{special?(rows) ? "Special" : "General"} Election #{YEAR}", "kind" => special?(rows) ? "special" : "general",
               "election_date" => date, "status" => "upcoming", "is_mock" => false, "is_historical" => false },
             "jurisdiction" => place[:code], "year" => "YEAR-#{YEAR}")
    end

    def special?(rows)
      rows.any? { |row| row.fetch("office").match?(/\bspecial\b/i) || row.fetch("notes", "").to_s.match?(/\bspecial election\b/i) }
    end

    def certification(rows)
      statuses = rows.map { |row| row.fetch("status") }.uniq
      mapped = statuses.map { |status| CERTIFICATION_STATUSES.find { |pattern, _| status.match?(pattern) }&.last }
      statuses.zip(mapped).each { |status, value| @certifications[status] << value }
      mapped.uniq.one? ? mapped.first : nil
    end

    def username_for(key, parts, seat)
      return @usernames.fetch(key) if @usernames.key?(key)

      surname_words = parts[:last_name].delete(",").split
      surname_words.pop if surname_words.size > 1 && surname_words.last.match?(BallotLineSeeder::NAME_SUFFIX)
      base = [ slug(surname_words.last), (slug(parts[:first_name]) if parts[:first_name]), @state_code.downcase, seat ].compact.join("_").squeeze("_")
      taken = @usernames.values.to_set + @issued.values
      username = base
      username = "#{base}_#{(2..).find { |n| !taken.include?("#{base}_#{n}") }}" if taken.include?(base)
      @issued[key] = @usernames[key] = username
    end

    def slug(text)
      ActiveSupport::Inflector.transliterate(text).downcase.delete("'").gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
    end

    def token(text)
      slug(text).upcase
    end

    def record(type, code, attributes = {}, references = {})
      { "type" => type, "code" => code, "attributes" => attributes, "references" => references }.reject { |_, value| value.respond_to?(:empty?) && value.empty? }
    end

    def write_manifests(race_groups)
      positions = race_groups.map { |group| group[:position] }.uniq
      write_foundation(positions)
      parties = @qualified.map { |label, code| record("Party", "PARTY-#{@state_path}-#{code}", { "name" => label }) }
      districts = race_groups.filter_map { |group| group[:district] }.uniq { |district| district["code"] }
      write_manifest(manifest_dir.join("foundation.yml"), "#{@state_name}: state, qualified parties, and districts in this conversion.",
                     "records" => [ record("State", "STATE-#{@state_path}", { "code" => @state_code, "name" => @state_name }, "country" => "COUNTRY-USA") ],
                     "groups" => [ { "scope" => { "state" => "STATE-#{@state_path}" }, "records" => parties + districts } ])
      race_groups.group_by { |group| group[:file] }.each do |file, groups|
        elections = groups.map { |group| group[:election] }.uniq { |election| election["code"] }
        write_manifest(manifest_dir.join("#{file}.yml"), "#{@state_name} #{file.tr("_", " ")} contests on the #{YEAR} general election ballot.",
                       "scope" => { "state" => "STATE-#{@state_path}" },
                       "records" => elections,
                       "groups" => groups.map { |group| { "records" => group[:records] } })
      end
    end

    # Shared across states: each conversion adds the positions it uses.
    def write_foundation(positions)
      path = @root.join("manifests", "foundation.yml")
      existing = path.exist? ? YAML.load_file(path).fetch("records") : [ record("Country", "COUNTRY-USA", { "code" => "US", "name" => "United States" }) ]
      added = positions.map { |position_token, title| record("Position", "POSITION-#{position_token}", { "title" => title }) }
      records = (existing + added).uniq { |entry| entry["code"] }
      records = records.select { |entry| entry["type"] == "Country" } + records.reject { |entry| entry["type"] == "Country" }.sort_by { |entry| entry["code"] }
      write_manifest(path, "Records shared by every state's conversion: the country and the positions on its ballots.", "records" => records)
    end

    def write_manifest(path, description, body)
      document = { "format" => "micharisma-seeds/v1", "namespace" => "MIC", "catalog" => "ASC" }.merge(body)
      write(path, "# #{description}\n# Generated by Seeds::BallotManifestConverter from the sourced ballot rows; edit the inputs, not this file.\n" +
                  document.to_yaml(line_width: -1).delete_prefix("---\n"))
    end

    def write(path, contents)
      FileUtils.mkdir_p(path.dirname)
      path.write(contents)
      @written_paths << path
    end

    def write_reports(contests)
      write(conversion_dir.join("usernames.yml"),
            "# Issued provisional usernames, keyed by office|district|printed name. Reused on every conversion; do not edit an issued username.\n" +
            @usernames.sort.to_h.to_yaml(line_width: -1).delete_prefix("---\n"))
      write(conversion_dir.join("name_spellings.yml"),
            "# Other spellings of a person's name found in cross-check sources. The ballot spelling is kept on the Person.\n" +
            name_spellings(contests).to_yaml(line_width: -1).delete_prefix("---\n"))
      write(conversion_dir.join("judgments.md"), judgments(contests))
    end

    def name_spellings(contests)
      @conflicts.select { |conflict| conflict["field"] == "candidate_name" && contests.key?([ conflict["office"], conflict["district"].to_s ]) }.map do |conflict|
        {
          "username" => @usernames["#{conflict["office"]}|#{conflict["district"]}|#{conflict["candidate_name"]}"],
          "ballot_spelling" => conflict["value_a"],
          "other_spelling" => conflict["value_b"],
          "other_source" => conflict["source_b"],
          "note" => conflict["note"]
        }
      end
    end

    def judgments(contests)
      conflicts_in = ->(field) { @conflicts.select { |conflict| conflict["field"] == field && contests.key?([ conflict["office"], conflict["district"].to_s ]) } }
      lines = [ "# #{@state_name} #{YEAR} conversion judgments", "", "Generated by `Seeds::BallotManifestConverter` (selection: #{@selection}). Each item below is a decision the conversion made or left open; review them before relying on the manifests.", "" ]
      lines += [ "## Contests converted", "" ]
      if @selection == :pilot
        lines << "Selection rule: every statewide contest among #{PILOT_STATEWIDE_OFFICES.uniq.join(", ")}; for each of #{PILOT_DISTRICT_OFFICES.join(", ")}, the #{PILOT_CONTESTS_PER_OFFICE} districts with the most distinct candidates (then the most printed lines, then the lowest district number); plus every contest in those offices with a logged source conflict."
        lines << ""
      end
      contests.keys.group_by(&:first).each do |office, keys|
        lines << "- #{office}: #{keys.map(&:last).map { |district| district.empty? ? "statewide" : district }.join(", ")}"
      end
      lines += [ "", "## Party classification", "", "Qualified parties, from `parties.yml`: #{@qualified.keys.join(", ")}. Their lines link to Party records and count as the party's endorsement." ]
      if @designations.any?
        lines << "Other printed labels were converted as #{@other_label_kind} lines with no Party: #{@designations.sort.join(", ")}."
      end
      lines += [ "", "## People included off the ballot", "" ]
      lines += @off_ballot.any? ? @off_ballot.map { |conflict| "- #{conflict["candidate_name"]} (#{contest_label(conflict)}): #{conflict["note"]}. Included with participation `off_ballot` and no ballot line; the official source does not list them." } : [ "None." ]
      lines += [ "", "## Name spellings", "", "#{name_spellings(contests).size} other spellings are recorded in `name_spellings.yml`. Each Person keeps the official ballot spelling." ]
      lines += [ "", "## Conflicts not applied", "" ]
      (conflicts_in.call("party") + conflicts_in.call("incumbent")).each do |conflict|
        lines << "- #{conflict["candidate_name"]} (#{contest_label(conflict)}), #{conflict["field"]}: kept `#{conflict["value_a"]}`; other source has `#{conflict["value_b"]}`. #{conflict["note"]}"
      end
      lines += [ "", "## Certification status", "" ]
      @certifications.each { |status, values| lines << "- `#{status}` → #{values.map { |value| value ? "`#{value}`" : "not mapped (left blank)" }.join(", ")}" }
      lines += [ "", "## Fields not stored", "", "The manifests do not store #{UNMAPPED_FIELDS.map { |field| "`#{field}`" }.join(", ")}. They remain in the source rows under `races/#{YEAR}/#{@state_dir}/`." ]
      surname_only = @usernames.select { |key, _| contests.key?(key.split("|").first(2)) }.keys.map { |key| key.split("|").last }.select { |name| name.split.one? }
      lines += [ "", "## Missing evidence", "", surname_only.any? ? "Printed with a surname only: #{surname_only.join(", ")}." : "No person is printed with a surname only." ]
      lines.join("\n") + "\n"
    end

    def contest_label(conflict)
      conflict["district"].to_s.empty? ? conflict["office"] : "#{conflict["office"]} #{conflict["district"]}"
    end
  end
end
