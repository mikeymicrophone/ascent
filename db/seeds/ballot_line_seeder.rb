class BallotLineSeeder
  DATA_GLOB = ["races", "2026", "*", "{federal,state,local}", "*.yml"].freeze
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

  LABEL_KINDS = { "Write-In" => "write_in", "Petitioning Candidate" => "petition" }.freeze

  NAME_SUFFIX = /\A(?:jr|sr|ii|iii|iv|v|esq|esquire)\.?\z/i

  def self.seed(paths = SeedDataPaths.glob(*DATA_GLOB))
    @races = {}
    @states = {}
    rows = paths.sort.flat_map { |path| rows_from(path) }

    rows.group_by { |row| race_for(row) }.each do |race, race_rows|
      race.update!(description: race_description(race_rows))
      race_rows.group_by { |row| row.fetch("candidate_name") }.each do |name, candidate_rows|
        seed_candidacy(race, name, candidate_rows)
      end
    end

    puts "Seeded #{rows.size} ballot lines from #{paths.size} files"
    rows
  end

  def self.rows_from(path)
    rows = YAML.load_file(path)
    raise "#{path} must contain a list of ballot lines" unless rows.is_a?(Array)

    rows.each do |row|
      missing = REQUIRED_KEYS.reject { |key| row.key?(key) }
      raise "#{path} is missing #{missing.join(", ")}" if missing.any?
    end

    rows
  end

  # The printed name, split so that Person#full_name reproduces it.
  def self.name_parts(printed_name)
    words = printed_name.split
    suffix = words.pop if words.size > 2 && words.last.match?(NAME_SUFFIX)
    last_name = [ words.pop, suffix ].compact.join(" ")

    { first_name: words.shift, middle_name: words.join(" ").presence, last_name: last_name }
  end

  def self.race_for(row)
    office = office_for(row)
    @races[[ office.id, row.fetch("election_date") ]] ||= Race.find_or_create_by!(
      election: SeedJurisdictions.general_election(office.jurisdiction, row.fetch("election_date")),
      office: office
    ) { |race| race.status = "upcoming" }
  end
  private_class_method :race_for

  def self.office_for(row)
    position, jurisdiction, seat = row.fetch("office_level") == "local" ? local_placement(row) : state_level_placement(row)
    seat = "Retention of #{row.fetch("candidate_name")}" if row.fetch("notes", "").include?("merit retention")

    Office.find_or_create_by!(position: position, jurisdiction: jurisdiction, notes: seat) do |office|
      office.is_active = true
    end
  end
  private_class_method :office_for

  def self.state_level_placement(row)
    state = state_for(row)
    position_title, district_kind = STATE_LEVEL_OFFICES.fetch(row.fetch("office")) do
      raise KeyError, "No position mapping for #{row.fetch("state")} office #{row.fetch("office").inspect}"
    end
    position = Position.find_by!(title: position_title)
    district = row.fetch("district")
    return [ position, state.jurisdiction, nil ] if district.blank?

    number, seat = district.match(/\ACircuit (\d+)(?:, (.+))?\z/)&.captures || [ district, nil ]
    separator = number.match?(/\A\d+\z/) ? " " : ": "
    [ position, district_jurisdiction(state, "#{state.name} #{district_kind}#{separator}#{number}", district_kind), seat ]
  end
  private_class_method :state_level_placement

  # Local offices belong to the most specific single place the source names.
  # Contests spanning several places get a District named for the office and those places.
  def self.local_placement(row)
    state = state_for(row)
    office_title = row.fetch("office")
    position = Position.find_or_create_by!(title: office_title) do |record|
      record.description = "Office title as printed on 2026 official candidate lists."
    end
    localities = places(row["jurisdiction"])
    towns = localities.reject { |place| county_name?(place) }
    counties = (places(row["county"]) + (localities - towns)).uniq { |place| title_case(place) }
    seat = row.fetch("district").presence

    if towns.one?
      county = county_for(state, counties.first) if counties.one?
      [ position, municipality_jurisdiction(state, title_case(towns.first), county), seat ]
    elsif towns.empty? && counties.one?
      [ position, county_for(state, counties.first).jurisdiction, seat ]
    elsif towns.empty? && counties.empty?
      [ position, district_jurisdiction(state, "#{state.name} #{office_title}: #{seat}", "#{office_title} district"), nil ]
    else
      covered = (towns.presence || counties).map { |place| title_case(place) }.join(", ")
      [ position, district_jurisdiction(state, "#{state.name} #{office_title} (#{covered})", "#{office_title} district"), seat ]
    end
  end
  private_class_method :local_placement

  def self.seed_candidacy(race, printed_name, candidate_rows)
    parts = name_parts(printed_name)
    person = race.candidacies.joins(:person).find_by(people: parts)&.person || Person.create!(parts)
    candidacy = Candidacy.find_or_initialize_by(race: race, person: person)
    candidacy.status = "active"
    candidacy.save!
    seed_ballot_lines(candidacy, candidate_rows.map { |row| row.fetch("party") }.compact_blank.uniq)
  end
  private_class_method :seed_candidacy

  # Lines are added, never removed: a partial capture must not clear another line.
  # Telling parties from political designations needs each state's party list, so
  # labels other than write-ins and petitions stay unclassified until conversion.
  def self.seed_ballot_lines(candidacy, labels)
    labels.each.with_index(1) do |label, position|
      candidacy.ballot_lines.find_or_create_by!(label: label) do |line|
        line.kind = LABEL_KINDS.fetch(label, "unclassified")
        line.position = position
      end
    end
  end
  private_class_method :seed_ballot_lines

  def self.race_description(rows)
    [
      labelled("Vote for", rows.map { |row| row["vote_for"] }),
      labelled("Source status", rows.map { |row| row.fetch("status") }),
      labelled("Retrieved", rows.map { |row| row.fetch("retrieved_on") }),
      labelled("Sources", rows.map { |row| row.fetch("source_url") })
    ].compact.join(" ")
  end
  private_class_method :race_description

  def self.labelled(label, values)
    values = values.compact_blank.uniq
    "#{label}: #{values.join("; ")}." if values.any?
  end
  private_class_method :labelled

  def self.state_for(row)
    @states[row.fetch("state")] ||= State.joins(:country).find_by!(code: row.fetch("state"), countries: { code: "US" })
  end
  private_class_method :state_for

  def self.county_for(state, printed_name)
    name = title_case(printed_name.delete_suffix(" (NYC)"))
    name = "#{name} County" unless name.match?(/county\z/i)
    county = County.find_or_create_by!(state: state, name: name)
    SeedJurisdictions.ensure(county, parent: state.jurisdiction)
    county
  end
  private_class_method :county_for

  def self.municipality_jurisdiction(state, name, county)
    municipality = Municipality.find_or_create_by!(state: state, name: name) { |record| record.county = county }
    SeedJurisdictions.ensure(municipality, parent: (county || state).jurisdiction)
  end
  private_class_method :municipality_jurisdiction

  def self.district_jurisdiction(state, name, kind)
    district = District.find_or_create_by!(name: name) { |record| record.kind = kind.downcase }
    SeedJurisdictions.ensure(district, parent: state.jurisdiction)
  end
  private_class_method :district_jurisdiction

  def self.places(text)
    text.to_s.split(";").map(&:strip).compact_blank
  end
  private_class_method :places

  def self.county_name?(place)
    place.match?(/county\z/i)
  end
  private_class_method :county_name?

  # Some sources print place names in capitals ("TOWN OF CICERO").
  def self.title_case(text)
    return text unless text == text.upcase

    text.downcase.split.each_with_index.map do |word, index|
      index.positive? && %w[of and the on in at].include?(word) ? word : word.split("-").map(&:capitalize).join("-")
    end.join(" ")
  end
  private_class_method :title_case
end
