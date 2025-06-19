class ElectionSeeder
  def self.seed
    # Create elections for various offices and years
    create_presidential_elections
    create_gubernatorial_elections
    create_mayoral_elections
    create_mock_elections
    
    puts "Seeded #{Election.count} elections"
  end
  
  private
  
  def self.create_presidential_elections
    us = Country.find_by(name: "United States")
    president_position = Position.find_by(title: "President")
    
    return unless us && president_position
    
    us_president_office = Office.where(position: president_position, jurisdiction: us).first
    
    return unless us_president_office
    
    # Create presidential elections for presidential years
    Year.where(is_presidential_year: true).find_each do |year|
      Election.find_or_create_by(
        office: us_president_office,
        year: year
      ) do |election|
        election.election_date = Date.new(year.year, 11, first_tuesday_of_november(year.year))
        election.status = year.year <= Date.current.year ? "completed" : "upcoming"
        election.description = "Presidential Election - #{year.year}"
        election.is_mock = false
        election.is_historical = year.year < 2020
      end
    end
  end
  
  def self.create_gubernatorial_elections
    # Create governor elections for some states
    governor_position = Position.find_by(title: "Governor")
    return unless governor_position
    
    # Get some states for governor elections
    states = State.joins(:country).where(countries: { name: "United States" }).limit(5)
    
    states.each do |state|
      governor_office = state.offices.joins(:position).where(positions: { title: "Governor" }).first
      next unless governor_office
      
      # Create elections for even years
      Year.where(is_even_year: true).limit(3).find_each do |year|
        Election.find_or_create_by(
          office: governor_office,
          year: year
        ) do |election|
          election.election_date = Date.new(year.year, 11, first_tuesday_of_november(year.year))
          election.status = year.year <= Date.current.year ? "completed" : "upcoming"
          election.description = "Gubernatorial Election - #{state.name} #{year.year}"
          election.is_mock = false
          election.is_historical = year.year < 2022
        end
      end
    end
  end
  
  def self.create_mayoral_elections
    # Create mayor elections for cities with mayor offices
    Office.joins(:position).where(positions: { title: "Mayor" }).limit(3).find_each do |mayor_office|
      # Create elections for some recent years
      [2022, 2023, 2024].each do |year_num|
        year = Year.find_by(year: year_num)
        next unless year
        
        Election.find_or_create_by(
          office: mayor_office,
          year: year
        ) do |election|
          election.election_date = Date.new(year.year, 11, first_tuesday_of_november(year.year))
          election.status = year.year <= Date.current.year ? "completed" : "upcoming"
          election.description = "Mayoral Election - #{mayor_office.jurisdiction.name} #{year.year}"
          election.is_mock = false
          election.is_historical = false
        end
      end
    end
  end
  
  def self.create_mock_elections
    # Create some mock elections for educational purposes
    us = Country.find_by(name: "United States")
    president_position = Position.find_by(title: "President")
    
    return unless us && president_position
    
    us_president_office = Office.where(position: president_position, jurisdiction: us).first
    
    return unless us_president_office
    
    year_2024 = Year.find_by(year: 2024)
    return unless year_2024
    
    Election.find_or_create_by(
      office: us_president_office,
      year: year_2024,
      is_mock: true
    ) do |election|
      election.election_date = Date.new(2024, 3, 15)
      election.status = "active"
      election.description = "Mock Presidential Election 2024 - Educational Simulation"
      election.is_historical = false
    end
  end
  
  def self.first_tuesday_of_november(year)
    # Election Day is the first Tuesday after the first Monday in November
    first_day = Date.new(year, 11, 1)
    first_monday = first_day + ((8 - first_day.wday) % 7)
    first_tuesday = first_monday + 1
    first_tuesday.day
  end
end