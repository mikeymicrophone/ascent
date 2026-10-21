require "csv"
require Rails.root.join("db", "seeds", "data_paths").to_s

module Seeds
  # Converts one state's sourced 2026 ballot rows into micharisma-seeds/v1 manifests for the
  # Ascent catalog, and reports the judgments conversion cannot settle on its own.
  #
  # Reads   races/2026/<state>/{federal,state,local}/*.yml, races/2026/<state>/conflicts.csv,
  #         conversion/2026/<state>/rules.yml, and us_states.yml.
  # Writes  manifests/foundation.yml, manifests/2026/<state>/**/*.yml, and
  #         conversion/2026/<state>/{usernames.yml,name_spellings.yml,judgments.md}.
  #
  # Usernames already recorded in usernames.yml are reused, so a username never changes once issued.
  class BallotManifestConverter
    class Error < StandardError; end

    YEAR = 2026
    # Chamber token, seat prefix, manifest file, and whether one office fills the whole district.
    DISTRICT_KINDS = {
      "Congressional District" => [ "CONGRESS", "CD", "congress", true ],
      "State Senate District" => [ "SENATE", "SD", "state_senate", true ],
      "Assembly District" => [ "ASSEMBLY", "AD", "assembly", true ],
      "State House District" => [ "HOUSE", "HD", "state_house", true ],
      "House of Delegates District" => [ "HOUSE", "HD", "state_house", true ],
      "Governor's Council District" => [ "GOVERNORS_COUNCIL", "GC", "governors_council", true ],
      "Judicial District" => [ "JUDICIAL", "JD", "judicial", false ],
      "District Court of Appeal" => [ "APPEAL", "DCA", "judicial", false ],
      "Judicial Circuit" => [ "CIRCUIT", "CIR", "judicial", false ]
    }.freeze
    PILOT_STATEWIDE_OFFICES = [ "Governor", "Lt. Governor", "Lieutenant Governor", "Comptroller", "Attorney General" ].freeze
    PILOT_DISTRICT_OFFICES = [ "Representative in Congress", "State Senator", "Member of Assembly" ].freeze
    PILOT_CONTESTS_PER_OFFICE = 4
    CERTIFICATION_STATUSES = [ [ /tentative|subject to change/i, "tentative" ], [ /unofficial/i, "unofficial" ], [ /certified/i, "certified" ] ].freeze
    UNMAPPED_FIELDS = %w[incumbent fec_candidate_id county jurisdiction notes cross_check_url].freeze
    LOCAL_POSITION_DESCRIPTION = "Office title as printed on 2026 official candidate lists.".freeze

    attr_reader :summary

    def initialize(state_dir:, selection: :pilot, root: SeedDataPaths.primary_root)
      @state_dir, @selection, @root = state_dir, selection, Pathname.new(root)
    end

    def call
      load_inputs
      contests = selected_contests
      races = contests.map { |key, rows| placement(key, rows) }.group_by { |placed| placed[:race_code] }.map do |_, placed|
        race_manifest(placed)
      end

      write_manifests(races)
      write_reports(contests)
      @summary = {
        contests: races.size,
        candidacies: races.sum { |race| race[:candidacies] },
        off_ballot: @off_ballot.size,
        usernames_issued: @issued.size,
        files: @written_paths.size
      }
    end

    private

    def load_inputs
      paths = Dir.glob(@root.join("races", YEAR.to_s, @state_dir, "{federal,state,local}", "*.yml").to_s).sort
      raise Error, "No ballot rows for #{@state_dir}" if paths.empty?

      @rows = paths.flat_map { |path| BallotRows.rows_from(path) }
      @state_code = @rows.first.fetch("state")
      @state_name = YAML.load_file(@root.join("us_states.yml")).fetch("states").find { |state| state.fetch("code") == @state_code }.fetch("name")
      @state_path = "USA-#{@state_code}"
      conflicts_path = @root.join("races", YEAR.to_s, @state_dir, "conflicts.csv")
      @conflicts = conflicts_path.exist? ? CSV.read(conflicts_path, headers: true).map(&:to_h) : []
      load_rules(YAML.load_file(conversion_dir.join("rules.yml")))
      @usernames = (path = conversion_dir.join("usernames.yml")).exist? ? YAML.load_file(path) : {}
      # Titles defined in positions.yml keep their curated description, so manifests only reference them.
      @curated_titles = YAML.load_file(@root.join("positions.yml")).map { |position| position.fetch("title") }.to_set
      @positions = existing_foundation.select { |record| record["type"] == "Position" }.to_h do |record|
        record["attributes"].delete("description") if @curated_titles.include?(record["attributes"]["title"])
        [ record["attributes"]["title"], record ]
      end
      @places = {}
      @issued = {}
      @off_ballot = []
      @unplaced_conflicts = []
      @label_tally = Hash.new { |hash, key| hash[key] = Set.new }
      @certifications = Hash.new { |hash, key| hash[key] = Set.new }
      @specials = Set.new
      @split_counties = Set.new
      @written_paths = []
    end

    def load_rules(rules)
      @parties = rules.fetch("parties")
      @party_by_label = @parties.flat_map { |party| party.fetch("labels").map { |label| [ label, party ] } }.to_h
      @label_kinds = BallotRows::LABEL_KINDS.merge(rules.fetch("label_kinds", {}))
      @other_label_kind = rules.fetch("other_labels", "unclassified")
      @unprinted_labels = rules.fetch("unprinted_labels", [])
      @unprinted_levels = rules.fetch("unprinted_levels", [])
      @special_patterns = rules.fetch("special_elections", []).map { |pattern| Regexp.new(pattern, Regexp::IGNORECASE) }
    end

    def conversion_dir
      @root.join("conversion", YEAR.to_s, @state_dir)
    end

    def manifest_dir
      @root.join("manifests", YEAR.to_s, @state_dir)
    end

    def foundation_path
      @root.join("manifests", "foundation.yml")
    end

    def existing_foundation
      foundation_path.exist? ? YAML.load_file(foundation_path).fetch("records") : []
    end

    def local?(row)
      row.fetch("office_level") == "local"
    end

    def retention?(row)
      row.fetch("notes", "").to_s.include?("merit retention")
    end

    # Local contests are told apart by the places their rows name; a retention vote is one judge's own contest.
    def contest_key(row)
      key = [ row.fetch("office"), row.fetch("district") ]
      return key + [ row["county"].to_s, row["jurisdiction"].to_s ] if local?(row)
      return key + [ "retention: #{row.fetch("candidate_name")}" ] if retention?(row)

      key
    end

    # The pilot covers statewide contests, the most contested districts for each legislative and
    # congressional office, and every contest in those offices with a logged source conflict.
    def selected_contests
      contests = @rows.group_by { |row| contest_key(row) }
      return contests if @selection == :all

      conflicted = @conflicts.map { |conflict| [ conflict["office"], conflict["district"].to_s ] }
      chosen = contests.keys.select { |key| key.size == 2 && key.last.empty? && PILOT_STATEWIDE_OFFICES.include?(key.first) }
      PILOT_DISTRICT_OFFICES.each do |office|
        ranked = contests.select { |key, _| key.size == 2 && key.first == office }
                         .sort_by { |(_, district), rows| [ -rows.map { |row| row["candidate_name"] }.uniq.size, -rows.size, district.to_i ] }
        chosen += ranked.first(PILOT_CONTESTS_PER_OFFICE).map(&:first)
        chosen += ranked.map(&:first).select { |key| conflicted.include?(key) }
      end
      contests.slice(*chosen.uniq)
    end

    def placement(key, rows)
      placed = local?(rows.first) ? local_placement(rows) : state_level_placement(rows)
      contest = "#{YEAR}_#{special?(rows) ? "SPECIAL" : "GENERAL"}"
      @specials << key if special?(rows)
      placed.merge(
        key: key, rows: rows, contest: contest,
        election_code: "ELECTION-#{placed[:place][:path]}-#{contest}",
        race_code: "RACE-#{placed[:office_path]}-#{contest}"
      )
    end

    def state_level_placement(rows)
      row = rows.first
      position_title, district_kind = BallotRows::STATE_LEVEL_OFFICES.fetch(row.fetch("office")) do
        raise Error, "No position mapping for #{@state_code} office #{row.fetch("office").inspect}"
      end
      position_token = token(position_title)
      retention = "Retention of #{row.fetch("candidate_name")}" if retention?(row)
      district = row.fetch("district")
      if district.empty?
        return {
          position_code: position_code(position_title), place: state_place,
          office_path: [ "#{@state_path}-#{position_token}", (token(retention) if retention) ].compact.join("-"),
          seat_code: (token(retention) if retention),
          username_seat: [ position_token, ("RETENTION" if retention) ].compact.join("_").downcase,
          file: "statewide"
        }
      end

      chamber, prefix, file, single_seat = DISTRICT_KINDS.fetch(district_kind) { raise Error, "No district tokens for #{district_kind}" }
      number, group = district.match(/\ACircuit (\d+)(?:, (.+))?\z/)&.captures || [ district, nil ]
      numeric = number.match?(/\A\d+\z/)
      district_token = numeric ? "#{prefix}_#{number}" : token(number)
      place = district_place("#{@state_path}-#{chamber}-#{district_token}", "#{@state_name} #{district_kind}#{numeric ? " " : ": "}#{number}", district_kind)
      seat = retention || group
      if single_seat && seat.nil?
        office_path, seat_code, username_seat = place[:path], district_token, district_token.downcase
      else
        office_path = [ place[:path], position_token, (token(seat) if seat) ].compact.join("-")
        seat_code = [ district_token, (token(seat) if seat) ].compact.join("_")
        username_seat = [ district_token, (retention ? "RETENTION" : token(seat || position_title)) ].join("_").downcase
      end
      { position_code: position_code(position_title), place: place, office_path: office_path, seat_code: seat_code, username_seat: username_seat, file: file }
    end

    # Local offices belong to the most specific single place the source names. Contests spanning
    # several places, or naming none, get a District named for the office and what it covers.
    def local_placement(rows)
      row = rows.first
      office_title = row.fetch("office")
      localities = BallotRows.places(row["jurisdiction"])
      towns = localities.reject { |place| BallotRows.county_name?(place) }
      counties = (BallotRows.places(row["county"]) + (localities - towns)).uniq { |place| BallotRows.county_name(place) }
      seat = row.fetch("district").presence
      office_district = towns.many? || counties.many? || (towns.empty? && counties.empty?)

      place = if towns.one?
                municipality_place(BallotRows.title_case(towns.first), (county_place(counties.first) if counties.one?))
              elsif towns.empty? && counties.one?
                county_place(counties.first)
              elsif towns.empty? && counties.empty?
                covered, seat = seat, nil
                district_place("#{@state_path}-#{token(office_title)}-#{token(covered)}", "#{@state_name} #{office_title}: #{covered}", "#{office_title} district")
              else
                covered = towns.any? ? towns.map { |name| BallotRows.title_case(name) } : counties.map { |name| BallotRows.county_name(name) }
                district_place("#{@state_path}-#{token(office_title)}-#{token(covered.join(" "))}", "#{@state_name} #{office_title} (#{covered.join(", ")})", "#{office_title} district")
              end
      # A district drawn for this office already carries its title.
      office_path = [ place[:path], (token(office_title) unless office_district), (token(seat) if seat) ].compact.join("-")
      {
        position_code: position_code(office_title, local: true), place: place, office_path: office_path,
        seat_code: (token(seat) if seat), username_seat: office_path.delete_prefix("#{@state_path}-").downcase.tr("-", "_"),
        file: "local/#{counties.one? ? slug(BallotRows.county_name(counties.first).delete_suffix(" County")) : "multi_county"}"
      }
    end

    def state_place
      { code: "STATE-#{@state_path}", path: @state_path, name: @state_name }
    end

    def district_place(path, name, kind)
      add_place("DISTRICT-#{path}", record("District", "DISTRICT-#{path}", { "name" => name, "kind" => kind.downcase }))
      { code: "DISTRICT-#{path}", path: path, name: name }
    end

    def county_place(printed_name)
      name = BallotRows.county_name(printed_name)
      county_token = token(name.delete_suffix(" County"))
      code = "COUNTY-#{@state_path}-#{county_token}"
      add_place(code, record("County", code, { "name" => name }))
      { code: code, path: "#{@state_path}-COUNTY_#{county_token}", name: name }
    end

    def municipality_place(name, county)
      code = "MUNICIPALITY-#{@state_path}-#{token(name)}"
      definition = record("Municipality", code, { "name" => name }, county ? { "county" => county[:code] } : {})
      if (existing = @places[code]) && existing["references"] != definition["references"]
        # A town listed under different counties is recorded without one.
        @split_counties << name
        existing.delete("references")
      else
        add_place(code, definition)
      end
      { code: code, path: "#{@state_path}-#{token(name)}", name: name }
    end

    def add_place(code, definition)
      @places[code] ||= definition
    end

    def position_code(title, local: false)
      @positions[title] ||= begin
        base = "POSITION-#{token(title)}"
        taken = @positions.values.map { |record| record["code"] }
        code = taken.include?(base) ? "#{base}_#{(2..).find { |n| !taken.include?("#{base}_#{n}") }}" : base
        record("Position", code, { "title" => title, "description" => (LOCAL_POSITION_DESCRIPTION if local && !@curated_titles.include?(title)) }.compact)
      end
      @positions[title]["code"]
    end

    def race_manifest(placed)
      first = placed.first
      rows = placed.flat_map { |contest| contest[:rows] }
      office_code = "OFFICE-#{first[:office_path]}"
      records = [
        record("Office", office_code, { "seat_code" => first[:seat_code], "is_active" => true }.compact,
               "position" => first[:position_code], "jurisdiction" => first[:place][:code]),
        record("Race", first[:race_code], { "status" => "upcoming", "certification_status" => certification(rows), "description" => BallotRows.race_description(rows) }.compact,
               "election" => first[:election_code], "office" => office_code)
      ]
      candidates = placed.flat_map { |contest| contest[:rows].map { |row| [ row.fetch("candidate_name"), contest, row ] } }.group_by(&:first)
      candidacies = candidates.map do |name, entries|
        candidate_records(name, entries.map(&:last), registry_key(entries.first[1][:key], name), first, "active")
      end
      placed.select { |contest| contest[:key].size == 2 }.each do |contest|
        off_ballot_names(contest).each do |name|
          candidacies << candidate_records(name, [], registry_key(contest[:key], name), first, "off_ballot")
        end
      end

      { file: first[:file], election: election_record(first, rows), records: records + candidacies.flatten, candidacies: candidacies.size }
    end

    def registry_key(contest_key, name)
      (contest_key.first(2) + (contest_key.size == 4 ? contest_key.last(2) : []) + [ name ]).join("|")
    end

    def candidate_records(name, rows, key, placed, participation)
      parts = BallotRows.name_parts(name)
      username = username_for(key, parts, placed[:username_seat])
      person = record("Person", "PERSON-#{username.upcase}",
                      { "username" => username, "username_status" => "provisional" }.merge(parts.transform_keys(&:to_s).compact))
      lines = rows.filter_map { |row| ballot_line(row) }.uniq { |line| line["label"] }
      attributes = { "status" => "active", "participation" => participation }
      attributes["ballot_lines"] = lines if lines.any?
      candidacy = record("Candidacy", "CANDIDACY-#{placed[:office_path]}-#{placed[:contest]}-#{username.upcase}", attributes,
                         "race" => placed[:race_code], "person" => person["code"])
      [ person, candidacy ]
    end

    def ballot_line(row)
      label = row.fetch("party")
      return if label.blank?

      if @unprinted_levels.include?(row.fetch("office_level")) || @unprinted_labels.include?(label)
        @label_tally["not printed"] << label
        return
      end
      if (party = @party_by_label[label])
        @label_tally["party"] << label
        { "label" => label, "kind" => "party", "party" => "PARTY-#{@state_path}-#{party.fetch("code")}" }
      else
        kind = @label_kinds.fetch(label, @other_label_kind)
        @label_tally[kind] << label
        { "label" => label, "kind" => kind }
      end
    end

    # Sources disagreeing on whether a person belongs in the contest: include them, off the ballot.
    def off_ballot_names(contest)
      office, district = contest[:key]
      printed = contest[:rows].map { |row| row["candidate_name"] }
      @conflicts.select { |conflict| conflict["field"] == "presence" && conflict["office"] == office && conflict["district"].to_s == district && absent_from_official_source?(conflict) }
                .reject { |conflict| printed.include?(conflict["candidate_name"]) }
                .each { |conflict| @off_ballot << conflict }
                .map { |conflict| conflict["candidate_name"] }
                .uniq
    end

    # Sources word this differently: "not listed", "(not on SoS list)", "(no DOS line)".
    def absent_from_official_source?(conflict)
      conflict["value_a"].to_s.match?(/\A\(?(?:not|no)\b/i)
    end

    def election_record(placed, rows)
      special = placed[:contest].end_with?("SPECIAL")
      record("Election", placed[:election_code],
             { "name" => "#{placed[:place][:name]} #{special ? "Special" : "General"} Election #{YEAR}", "kind" => special ? "special" : "general",
               "election_date" => rows.first.fetch("election_date"), "status" => "upcoming", "is_mock" => false, "is_historical" => false },
             "jurisdiction" => placed[:place][:code], "year" => "YEAR-#{YEAR}")
    end

    def special?(rows)
      rows.any? { |row| @special_patterns.any? { |pattern| row.fetch("office").match?(pattern) || row.fetch("notes", "").to_s.match?(pattern) } }
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
      surname_words.pop if surname_words.size > 1 && surname_words.last.match?(BallotRows::NAME_SUFFIX)
      base = [ slug(surname_words.last), (slug(parts[:first_name]) if parts[:first_name]), @state_code.downcase, seat ].compact_blank.join("_").squeeze("_")
      @taken ||= @usernames.values.to_set
      username = base
      username = "#{base}_#{(2..).find { |n| !@taken.include?("#{base}_#{n}") }}" if @taken.include?(base)
      @taken << username
      @issued[key] = @usernames[key] = username
    end

    def slug(text)
      ActiveSupport::Inflector.transliterate(text.to_s).downcase.delete("'").gsub(/[^a-z0-9]+/, "_").gsub(/\A_+|_+\z/, "")
    end

    def token(text)
      slug(text).upcase
    end

    def record(type, code, attributes = {}, references = {})
      { "type" => type, "code" => code, "attributes" => attributes, "references" => references }.reject { |_, value| value.respond_to?(:empty?) && value.empty? }
    end

    def write_manifests(races)
      FileUtils.rm_rf(manifest_dir)
      write_foundation
      parties = @parties.map { |party| record("Party", "PARTY-#{@state_path}-#{party.fetch("code")}", { "name" => party.fetch("name") }) }
      places = @places.values.sort_by { |place| [ %w[County Municipality District].index(place["type"]), place["code"] ] }
      write_manifest(manifest_dir.join("foundation.yml"), "#{@state_name}: the state, its parties, and the places its contests belong to.",
                     "records" => [ record("State", "STATE-#{@state_path}", { "code" => @state_code, "name" => @state_name }, "country" => "COUNTRY-USA") ],
                     "groups" => [ { "scope" => { "state" => "STATE-#{@state_path}" }, "records" => parties + places } ])
      races.group_by { |race| race[:file] }.sort.each do |file, file_races|
        elections = file_races.map { |race| race[:election] }.uniq { |election| election["code"] }
        write_manifest(manifest_dir.join("#{file}.yml"), "#{@state_name} #{file.delete_prefix("local/").tr("_", " ")} contests on the #{YEAR} general election ballot.",
                       "scope" => { "state" => "STATE-#{@state_path}" },
                       "records" => elections,
                       "groups" => file_races.map { |race| { "records" => race[:records] } })
      end
    end

    # Shared across states: each conversion adds the positions it uses.
    def write_foundation
      country = existing_foundation.find { |entry| entry["type"] == "Country" } || record("Country", "COUNTRY-USA", { "code" => "US", "name" => "United States" })
      write_manifest(foundation_path, "Records shared by every state's conversion: the country and the positions on its ballots.",
                     "records" => [ country ] + @positions.values.sort_by { |entry| entry["code"] })
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
            "# Issued provisional usernames, keyed by contest and printed name. Reused on every conversion; do not edit an issued username.\n" +
            @usernames.sort.to_h.to_yaml(line_width: -1).delete_prefix("---\n"))
      write(conversion_dir.join("name_spellings.yml"),
            "# Other spellings of a person's name found in cross-check sources. The ballot spelling is kept on the Person.\n" +
            name_spellings(contests).to_yaml(line_width: -1).delete_prefix("---\n"))
      write(conversion_dir.join("judgments.md"), judgments(contests))
    end

    # A conflict names an office and district; it belongs to the converted contest whose rows include its person.
    def conflict_contest(conflict, contests)
      matches = contests.select do |(office, district), rows|
        office == conflict["office"] && district == conflict["district"].to_s && rows.any? { |row| row["candidate_name"] == conflict["candidate_name"] }
      end
      matches.size == 1 ? matches.keys.first : nil
    end

    def name_spellings(contests)
      @conflicts.select { |conflict| conflict["field"] == "candidate_name" }.filter_map do |conflict|
        key = conflict_contest(conflict, contests)
        next unless key

        {
          "username" => @usernames[registry_key(key, conflict["candidate_name"])],
          "ballot_spelling" => conflict["value_a"],
          "other_spelling" => conflict["value_b"],
          "other_source" => conflict["source_b"],
          "note" => conflict["note"]
        }
      end
    end

    def judgments(contests)
      in_selection = ->(conflict) { conflict_contest(conflict, contests) }
      lines = [ "# #{@state_name} #{YEAR} conversion judgments", "",
                "Generated by `Seeds::BallotManifestConverter` (selection: #{@selection}). Each item below is a decision the conversion made or left open; review them before relying on the manifests.", "" ]
      lines += [ "## Contests converted", "" ]
      if @selection == :pilot
        lines << "Selection rule: every statewide contest among #{PILOT_STATEWIDE_OFFICES.uniq.join(", ")}; for each of #{PILOT_DISTRICT_OFFICES.join(", ")}, the #{PILOT_CONTESTS_PER_OFFICE} districts with the most distinct candidates (then the most printed lines, then the lowest district number); plus every contest in those offices with a logged source conflict."
        lines << ""
      end
      lines << "#{contests.size} source contests from #{contests.values.sum(&:size)} rows: #{contests.keys.count { |key| key.size == 4 }} local, #{contests.keys.count { |key| key.size != 4 }} federal and state."
      if @specials.any?
        lines += [ "", "Special elections (matched by `rules.yml`): #{@specials.map { |key| key.first(2).compact_blank.join(" ") }.uniq.sort.join("; ")}." ]
      end
      lines += [ "", "## Ballot line labels", "", "Rules come from `rules.yml`. Party lines link to Party records and count as the party's endorsement." ]
      @label_tally.sort.each { |kind, labels| lines << "- #{kind}: #{labels.sort.join(", ")}" }
      lines += [ "", "## People included off the ballot", "" ]
      lines += @off_ballot.any? ? @off_ballot.map { |conflict| "- #{conflict["candidate_name"]} (#{contest_label(conflict)}): #{conflict["note"]}. Included with participation `off_ballot` and no ballot line." } : [ "None." ]
      lines += [ "", "## Name spellings", "", "#{name_spellings(contests).size} other spellings are recorded in `name_spellings.yml`. Each Person keeps the official ballot spelling." ]
      applied = %w[candidate_name]
      placed = @conflicts.select { |conflict| conflict["field"] == "presence" ? @off_ballot.include?(conflict) : applied.include?(conflict["field"]) && in_selection.call(conflict) }
      remaining = @conflicts - placed
      lines += [ "", "## Conflicts not applied", "" ]
      lines += remaining.any? ? remaining.map { |conflict| "- #{conflict["candidate_name"]} (#{contest_label(conflict)}), #{conflict["field"]}: kept `#{conflict["value_a"]}`; other source has `#{conflict["value_b"]}`. #{conflict["note"]}" } : [ "None." ]
      lines += [ "", "## Certification status", "" ]
      @certifications.sort.each { |status, values| lines << "- `#{status.presence || "(blank)"}` → #{values.map { |value| value ? "`#{value}`" : "not a certification status (left blank)" }.join(", ")}" }
      if @split_counties.any?
        lines += [ "", "## Towns listed under different counties", "", "Recorded without a county: #{@split_counties.sort.join(", ")}." ]
      end
      lines += [ "", "## Fields not stored", "", "The manifests do not store #{UNMAPPED_FIELDS.map { |field| "`#{field}`" }.join(", ")}. They remain in the source rows under `races/#{YEAR}/#{@state_dir}/`." ]
      surname_only = contests.values.flatten.map { |row| row["candidate_name"] }.uniq.select { |name| name.split.one? }
      lines += [ "", "## Missing evidence", "", surname_only.any? ? "Printed with a surname only: #{surname_only.join(", ")}." : "No person is printed with a surname only." ]
      lines.join("\n") + "\n"
    end

    def contest_label(conflict)
      conflict["district"].to_s.empty? ? conflict["office"] : "#{conflict["office"]} #{conflict["district"]}"
    end
  end
end
