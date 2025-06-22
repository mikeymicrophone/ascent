class GoverningBodySeeder
  def self.seed
    # Get available governance types and jurisdictions
    municipal_legislature = GovernanceType.find_by(name: "Municipal Legislature")
    county_executive = GovernanceType.find_by(name: "County Executive")
    county_legislature = GovernanceType.find_by(name: "County Legislature")
    state_legislature = GovernanceType.find_by(name: "State Legislature")
    state_executive = GovernanceType.find_by(name: "State Executive")
    school_board = GovernanceType.find_by(name: "School Board")
    special_district = GovernanceType.find_by(name: "Special District Board")
    federal_legislature = GovernanceType.find_by(name: "Federal Legislature")
    federal_executive = GovernanceType.find_by(name: "Federal Executive")
    
    # Get some representative jurisdictions
    us = Country.find_by(code: "US")
    california = State.find_by(code: "CA")
    new_york = State.find_by(code: "NY")
    texas = State.find_by(code: "TX")
    florida = State.find_by(code: "FL")
    
    # Get some cities for municipal bodies
    san_francisco = City.find_by(name: "San Francisco", state: california)
    los_angeles = City.find_by(name: "Los Angeles", state: california)
    new_york_city = City.find_by(name: "New York", state: new_york)
    austin = City.find_by(name: "Austin", state: texas)
    miami = City.find_by(name: "Miami", state: florida)
    
    governing_bodies = []
    
    # Federal Level Bodies
    if us && federal_legislature
      governing_bodies << {
        name: "United States Congress",
        jurisdiction_type: "Country",
        jurisdiction_id: us.id,
        governance_type_id: federal_legislature.id,
        description: "The bicameral legislature of the federal government of the United States consisting of the House of Representatives and the Senate.",
        meeting_schedule: "Year-round with recesses",
        is_active: true,
        established_date: Date.new(1789, 3, 4)
      }
    end
    
    if us && federal_executive
      governing_bodies << {
        name: "Executive Office of the President",
        jurisdiction_type: "Country",
        jurisdiction_id: us.id,
        governance_type_id: federal_executive.id,
        description: "The executive branch of the United States federal government, headed by the President.",
        meeting_schedule: "Continuous",
        is_active: true,
        established_date: Date.new(1789, 4, 30)
      }
    end
    
    # State Level Bodies
    [
      { state: california, abbrev: "CA" },
      { state: new_york, abbrev: "NY" },
      { state: texas, abbrev: "TX" },
      { state: florida, abbrev: "FL" }
    ].each do |state_info|
      state = state_info[:state]
      abbrev = state_info[:abbrev]
      next unless state
      
      if state_legislature
        governing_bodies << {
          name: "#{state.name} State Legislature",
          jurisdiction_type: "State",
          jurisdiction_id: state.id,
          governance_type_id: state_legislature.id,
          description: "The state legislature of #{state.name}, responsible for making state laws and appropriating the state budget.",
          meeting_schedule: "Annual sessions",
          is_active: true,
          established_date: case abbrev
                           when "CA" then Date.new(1849, 9, 9)
                           when "NY" then Date.new(1777, 4, 20)
                           when "TX" then Date.new(1845, 12, 29)
                           when "FL" then Date.new(1845, 3, 3)
                           else Date.new(1850, 1, 1)
                           end
        }
      end
      
      if state_executive
        governing_bodies << {
          name: "Office of the Governor of #{state.name}",
          jurisdiction_type: "State",
          jurisdiction_id: state.id,
          governance_type_id: state_executive.id,
          description: "The executive branch of #{state.name} state government, headed by the Governor.",
          meeting_schedule: "Continuous",
          is_active: true,
          established_date: case abbrev
                           when "CA" then Date.new(1849, 12, 20)
                           when "NY" then Date.new(1777, 7, 30)
                           when "TX" then Date.new(1845, 12, 29)
                           when "FL" then Date.new(1845, 6, 25)
                           else Date.new(1850, 1, 1)
                           end
        }
      end
    end
    
    # Municipal Bodies
    [
      { city: san_francisco, county: "San Francisco" },
      { city: los_angeles, county: "Los Angeles" },
      { city: new_york_city, county: "New York" },
      { city: austin, county: "Travis" },
      { city: miami, county: "Miami-Dade" }
    ].each do |city_info|
      city = city_info[:city]
      county = city_info[:county]
      next unless city && municipal_legislature
      
      governing_bodies << {
        name: "#{city.name} City Council",
        jurisdiction_type: "City",
        jurisdiction_id: city.id,
        governance_type_id: municipal_legislature.id,
        description: "The legislative body of the City of #{city.name}, responsible for local ordinances, budget approval, and municipal policy.",
        meeting_schedule: "Weekly",
        is_active: true,
        established_date: case city.name
                         when "San Francisco" then Date.new(1850, 4, 15)
                         when "Los Angeles" then Date.new(1850, 4, 4)
                         when "New York" then Date.new(1653, 2, 2)
                         when "Austin" then Date.new(1839, 12, 27)
                         when "Miami" then Date.new(1896, 7, 28)
                         else Date.new(1900, 1, 1)
                         end
      }
      
      # Add county executives where applicable
      if county_executive
        governing_bodies << {
          name: "#{county} County Executive",
          jurisdiction_type: "City", # Using city as proxy for county
          jurisdiction_id: city.id,
          governance_type_id: county_executive.id,
          description: "The chief executive officer of #{county} County, responsible for implementing county policies and managing county operations.",
          meeting_schedule: "As needed",
          is_active: true,
          established_date: Date.new(1950, 1, 1)
        }
      end
    end
    
    # School Boards
    [
      { city: san_francisco, name: "San Francisco Unified School District" },
      { city: los_angeles, name: "Los Angeles Unified School District" },
      { city: new_york_city, name: "New York City Department of Education" },
      { city: austin, name: "Austin Independent School District" },
      { city: miami, name: "Miami-Dade County Public Schools" }
    ].each do |school_info|
      city = school_info[:city]
      name = school_info[:name]
      next unless city && school_board
      
      governing_bodies << {
        name: "#{name} Board",
        jurisdiction_type: "City",
        jurisdiction_id: city.id,
        governance_type_id: school_board.id,
        description: "The governing board of #{name}, responsible for educational policy, budget oversight, and superintendent selection.",
        meeting_schedule: "Monthly",
        is_active: true,
        established_date: Date.new(1920, 1, 1)
      }
    end
    
    # Special Districts
    if special_district && san_francisco
      governing_bodies << {
        name: "San Francisco Bay Area Rapid Transit District Board",
        jurisdiction_type: "City",
        jurisdiction_id: san_francisco.id,
        governance_type_id: special_district.id,
        description: "The governing board of BART, responsible for transit policy, fare setting, and system expansion decisions.",
        meeting_schedule: "Bi-weekly",
        is_active: true,
        established_date: Date.new(1957, 5, 21)
      }
    end
    
    if special_district && los_angeles
      governing_bodies << {
        name: "Metropolitan Water District of Southern California Board",
        jurisdiction_type: "City",
        jurisdiction_id: los_angeles.id,
        governance_type_id: special_district.id,
        description: "The governing board responsible for water supply management and infrastructure for Southern California region.",
        meeting_schedule: "Monthly",
        is_active: true,
        established_date: Date.new(1928, 12, 6)
      }
    end
    
    # Create the governing bodies
    governing_bodies.each do |gb_attrs|
      governing_body = GoverningBody.find_or_create_by(
        name: gb_attrs[:name],
        jurisdiction_type: gb_attrs[:jurisdiction_type],
        jurisdiction_id: gb_attrs[:jurisdiction_id]
      ) do |gb|
        gb.governance_type_id = gb_attrs[:governance_type_id]
        gb.description = gb_attrs[:description]
        gb.meeting_schedule = gb_attrs[:meeting_schedule]
        gb.is_active = gb_attrs[:is_active]
        gb.established_date = gb_attrs[:established_date]
      end
      
      if governing_body.persisted?
        print "."
      else
        puts "\n❌ Failed to create governing body: #{gb_attrs[:name]}"
        puts "   Errors: #{governing_body.errors.full_messages.join(', ')}"
      end
    end
    
    puts " #{GoverningBody.count} governing bodies"
  end
end