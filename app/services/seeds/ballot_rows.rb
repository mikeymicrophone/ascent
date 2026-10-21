module Seeds
  # Reads the sourced ballot rows in the seed-data repository and interprets their printed text:
  # names, office titles, and the places a local contest names.
  module BallotRows
    DATA_GLOB = [ "races", "2026", "*", "{federal,state,local}", "*.yml" ].freeze
    REQUIRED_KEYS = %w[
      election_date
      state
      office
      district
      office_level
      candidate_name
      party
      incumbent
      status
      source_url
      retrieved_on
    ].freeze

    # Federal and state office titles are printed differently in each state.
    # Each maps to a shared Position and, for numbered seats, the kind of District that elects it.
    STATE_LEVEL_OFFICES = {
      "Representative in Congress" => [ "Representative", "Congressional District" ],
      "Member, House of Representatives" => [ "Representative", "Congressional District" ],
      "United States Representative" => [ "Representative", "Congressional District" ],
      "Senator in Congress" => [ "Senator" ],
      "Member, United States Senate" => [ "Senator" ],
      "United States Senator" => [ "Senator" ],
      "Governor" => [ "Governor" ],
      "Lt. Governor" => [ "Lieutenant Governor" ],
      "Lieutenant Governor" => [ "Lieutenant Governor" ],
      "Attorney General" => [ "Attorney General" ],
      "Secretary of State" => [ "Secretary of State" ],
      "Secretary of the State" => [ "Secretary of State" ],
      "Treasurer" => [ "Treasurer" ],
      "Comptroller" => [ "Comptroller" ],
      "Auditor" => [ "Auditor" ],
      "Chief Financial Officer" => [ "Chief Financial Officer" ],
      "Commissioner of Agriculture" => [ "Commissioner of Agriculture" ],
      "Councillor" => [ "Governor's Councillor", "Governor's Council District" ],
      "State Senator" => [ "State Senator", "State Senate District" ],
      "Senator in General Court" => [ "State Senator", "State Senate District" ],
      "Member of Assembly" => [ "State Representative", "Assembly District" ],
      "State Representative" => [ "State Representative", "State House District" ],
      "Representative in General Court" => [ "State Representative", "State House District" ],
      "Member, House of Delegates" => [ "State Representative", "House of Delegates District" ],
      "Supreme Court Justice" => [ "Justice", "Judicial District" ],
      "District Court of Appeal" => [ "Appellate Judge", "District Court of Appeal" ],
      "Circuit Judge" => [ "Circuit Judge", "Judicial Circuit" ],
      "State Attorney" => [ "State Attorney", "Judicial Circuit" ],
      "Public Defender" => [ "Public Defender", "Judicial Circuit" ]
    }.freeze

    # Labels with the same meaning in every state.
    LABEL_KINDS = { "Write-In" => "write_in", "Petitioning Candidate" => "petition" }.freeze
    NAME_SUFFIX = /\A(?:jr|sr|ii|iii|iv|v|esq|esquire)\.?\z/i
    SMALL_WORDS = %w[of and the on in at].freeze

    module_function

    def paths(root)
      Dir.glob(Pathname.new(root).join(*DATA_GLOB).to_s).sort
    end

    def rows_from(path)
      rows = YAML.load_file(path)
      raise "#{path} must contain a list of ballot lines" unless rows.is_a?(Array)

      rows.each do |row|
        missing = REQUIRED_KEYS.reject { |key| row.key?(key) }
        raise "#{path} is missing #{missing.join(", ")}" if missing.any?
      end

      rows
    end

    # The printed name, split so that Person#full_name reproduces it.
    def name_parts(printed_name)
      words = printed_name.split
      suffix = words.pop if words.size > 2 && words.last.match?(NAME_SUFFIX)
      last_name = [ words.pop, suffix ].compact.join(" ")

      { first_name: words.shift, middle_name: words.join(" ").presence, last_name: last_name }
    end

    def race_description(rows)
      [
        labelled("Vote for", rows.map { |row| row["vote_for"] }),
        labelled("Source status", rows.map { |row| row.fetch("status") }),
        labelled("Retrieved", rows.map { |row| row.fetch("retrieved_on") }),
        labelled("Sources", rows.map { |row| row.fetch("source_url") })
      ].compact.join(" ")
    end

    def labelled(label, values)
      values = values.compact_blank.uniq
      "#{label}: #{values.join("; ")}." if values.any?
    end

    def places(text)
      text.to_s.split(";").map(&:strip).compact_blank
    end

    def county_name?(place)
      place.match?(/county\z/i)
    end

    # "Erie", "ACCOMACK COUNTY", and "Kings (NYC)" become "Erie County", "Accomack County", and "Kings County".
    def county_name(printed_name)
      name = title_case(printed_name.delete_suffix(" (NYC)"))
      name.match?(/county\z/i) ? name : "#{name} County"
    end

    # Some sources print place names in capitals ("TOWN OF CICERO").
    def title_case(text)
      return text unless text == text.upcase

      text.downcase.split.each_with_index.map do |word, index|
        index.positive? && SMALL_WORDS.include?(word) ? word : word.split("-").map(&:capitalize).join("-")
      end.join(" ")
    end
  end
end
