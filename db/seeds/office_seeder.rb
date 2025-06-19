class OfficeSeeder
  def self.seed
    # Positions are seeded separately, but we can ensure jurisdictions exist
    # (Countries and States should already be seeded by the main seed file)
    
    # Create some example offices
    create_federal_offices
    create_state_offices
    create_local_offices
    
    puts "Seeded #{Office.count} offices"
  end
  
  private
  
  def self.create_federal_offices
    us = Country.find_by(name: "United States")
    return unless us
    
    president_position = Position.find_by(title: "President")
    if president_position
      Office.find_or_create_by(
        position: president_position,
        jurisdiction: us
      ) do |office|
        office.is_active = true
        office.notes = "President of the United States"
      end
    end
  end
  
  def self.create_state_offices
    # Create Governor offices for each state
    governor_position = Position.find_by(title: "Governor")
    return unless governor_position
    
    State.find_each do |state|
      Office.find_or_create_by(
        position: governor_position,
        jurisdiction: state
      ) do |office|
        office.is_active = true
        office.notes = "Governor of #{state.name}"
      end
    end
    
    # Create Senator offices (2 per state)
    senator_position = Position.find_by(title: "Senator")
    if senator_position
      State.find_each do |state|
        2.times do |i|
          Office.find_or_create_by(
            position: senator_position,
            jurisdiction: state,
            notes: "U.S. Senator from #{state.name} - Seat #{i + 1}"
          ) do |office|
            office.is_active = true
          end
        end
      end
    end
  end
  
  def self.create_local_offices
    # Create Mayor offices for some major cities
    mayor_position = Position.find_by(title: "Mayor")
    return unless mayor_position
    
    # Find some cities to create mayor offices for
    ["Los Angeles", "New York City", "Chicago", "Houston", "Phoenix"].each do |city_name|
      city = City.find_by(name: city_name)
      next unless city
      
      Office.find_or_create_by(
        position: mayor_position,
        jurisdiction: city
      ) do |office|
        office.is_active = true
        office.notes = "Mayor of #{city.name}"
      end
    end
  end
end