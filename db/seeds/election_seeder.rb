class ElectionSeeder
  def self.seed
    # Only create clearly-labelled educational simulations. Source-backed races
    # are seeded by their reference-data loaders.
    create_mock_elections
    
    puts "Seeded #{Election.count} elections"
  end
  
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
end
