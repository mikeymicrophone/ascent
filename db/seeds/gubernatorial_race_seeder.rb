class GubernatorialRaceSeeder
  DATA_GLOB = ["races", "2026", "governor", "*.yml"].freeze

  def self.seed(paths = SeedDataPaths.glob(*DATA_GLOB))
    paths.sort.each do |path|
      seed_race(YAML.load_file(path).fetch("race"))
    end

    puts "Seeded #{paths.count} sourced 2026 gubernatorial races"
  end

  def self.seed_race(race_data)
    state = State.joins(:country).find_by!(
      code: race_data.fetch("state_code"),
      countries: { code: race_data.fetch("country_code") }
    )
    position = Position.find_by!(title: "Governor")
    year = Year.find_or_create_by!(year: Date.iso8601(race_data.fetch("general_election_date")).year) do |record|
      record.is_even_year = true
      record.is_presidential_year = false
      record.description = "Midterm election year."
    end
    office = Office.find_or_create_by!(position: position, jurisdiction: state) do |record|
      record.is_active = true
      record.notes = "Governor of #{state.name}"
    end

    election = Election.find_or_initialize_by(office: office, year: year, is_mock: false)
    election.assign_attributes(
      election_date: Date.iso8601(race_data.fetch("general_election_date")),
      status: race_data.fetch("status"),
      is_historical: false,
      description: description_for(state, race_data)
    )
    election.save!
  end

  def self.description_for(state, race_data)
    source = race_data.fetch("source")

    "2026 #{state.name} gubernatorial general election. " \
      "Primary: #{Date.iso8601(race_data.fetch("primary_date")).strftime("%B %-d, %Y")}. " \
      "Source: #{source.fetch("title")} (accessed #{source.fetch("accessed_on")}): #{source.fetch("url")}"
  end
  private_class_method :description_for
end
