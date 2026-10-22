class ElectionSeeder
  def self.seed
    # Only create clearly-labelled educational simulations. Source-backed races
    # are seeded by their reference-data loaders.
    create_mock_elections
    create_mock_local_elections
    
    puts "Seeded #{Election.count} elections"
  end
  
  # The simulated candidates' races, from city hall up to the governor's office.
  # Mayor and Council Member share the demo city; the others prefer offices in its state.
  MOCK_CITY = "Los Angeles"
  MOCK_LOCAL_POSITIONS = [
    "Mayor", "Council Member", "Sheriff", "School Board", "County Commissioner",
    "District Attorney", "State Representative", "State Senator", "Governor"
  ].freeze

  private
  
  def self.create_mock_elections
    # Create some mock elections for educational purposes
    us = Country.find_by(name: "United States")
    president_position = Position.find_by(title: "President")
    
    return unless us && president_position
    
    us_president_office = Office.where(position: president_position, jurisdiction: us.jurisdiction).first
    
    return unless us_president_office
    
    year_2024 = Year.find_by(year: 2024)
    return unless year_2024
    
    election = Election.find_or_create_by(
      jurisdiction: us.jurisdiction,
      year: year_2024,
      is_mock: true
    ) do |election|
      election.name = "Mock Presidential Election 2024"
      election.election_date = Date.new(2024, 3, 15)
      election.status = "active"
      election.description = "Mock Presidential Election 2024 - Educational Simulation"
      election.is_historical = false
    end

    Race.find_or_create_by(election: election, office: us_president_office) do |race|
      race.status = "active"
    end
  end

  def self.create_mock_local_elections
    city = Municipality.find_by(name: MOCK_CITY)
    year_2024 = Year.find_by(year: 2024)
    return unless city && year_2024

    MOCK_LOCAL_POSITIONS.each do |title|
      office = mock_office_for(title, city)
      next unless office

      election = Election.find_or_create_by(jurisdiction: office.jurisdiction, year: year_2024, is_mock: true) do |election|
        election.name = "Mock #{office.jurisdiction.name} Election 2024"
        election.election_date = Date.new(2024, 11, 5)
        election.status = "active"
        election.description = "Mock #{office.jurisdiction.name} Election 2024 - Educational Simulation"
        election.is_historical = false
      end

      Race.find_or_create_by(election: election, office: office) do |race|
        race.status = "active"
      end
    end
  end

  def self.mock_office_for(title, city)
    offices = Office.joins(:position).where(positions: { title: title }).order(:id)

    offices.find_by(jurisdiction: city.jurisdiction) ||
      offices.find_by(jurisdiction_id: city.state.jurisdiction.self_and_descendants.select(:id)) ||
      offices.first
  end
end
