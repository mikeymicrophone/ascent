class GoverningBodySeeder
  def self.seed
    # Get available governance types and jurisdictions
    legislature = GovernanceType.find_by(name: "Legislature")
    court = GovernanceType.find_by(name: "Court")
    council = GovernanceType.find_by(name: "Council")
    board = GovernanceType.find_by(name: "Board")
    executive = GovernanceType.find_by(name: "Executive")
    
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
    if us && legislature
      governing_bodies << {
        name: "United States Congress",
        jurisdiction_type: "Country",
        jurisdiction_id: us.id,
        governance_type_id: legislature.id,
        branch: :legislative,
        description: "The bicameral legislature of the federal government of the United States consisting of the House of Representatives and the Senate.",
        meeting_schedule: "Year-round with recesses",
        is_active: true,
        established_date: Date.new(1789, 3, 4),
        chambers: [
          { name: "Senate", description: "The upper house of the United States Congress." },
          { name: "House of Representatives", description: "The lower house of the United States Congress." }
        ]
      }
    end

    if us && court
      governing_bodies << {
        name: "Supreme Court of the United States",
        jurisdiction_type: "Country",
        jurisdiction_id: us.id,
        governance_type_id: court.id,
        branch: :judicial,
        description: "The court of last resort of the United States, responsible for interpreting the Constitution and federal law.",
        meeting_schedule: "Scheduled terms",
        is_active: true,
        established_date: Date.new(1789, 9, 24)
      }
    end
    
    if us && executive
      governing_bodies << {
        name: "Executive Office of the President",
        jurisdiction_type: "Country",
        jurisdiction_id: us.id,
        governance_type_id: executive.id,
        branch: :executive,
        description: "The executive institution of the United States federal government, headed by the President.",
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
      
      if legislature
        governing_bodies << {
          name: "#{state.name} State Legislature",
          jurisdiction_type: "State",
          jurisdiction_id: state.id,
          governance_type_id: legislature.id,
          branch: :legislative,
          description: "The state legislature of #{state.name}, responsible for making state laws and appropriating the state budget.",
          meeting_schedule: "Annual sessions",
          is_active: true,
          established_date: case abbrev
                           when "CA" then Date.new(1849, 9, 9)
                           when "NY" then Date.new(1777, 4, 20)
                           when "TX" then Date.new(1845, 12, 29)
                           when "FL" then Date.new(1845, 3, 3)
                           else Date.new(1850, 1, 1)
                           end,
          chambers: [
            { name: "Senate", description: "The upper house of the #{state.name} State Legislature." },
            { name: lower_house_name(abbrev), description: "The lower house of the #{state.name} State Legislature." }
          ]
        }
      end

      if court
        governing_bodies << {
          name: court_name(state, abbrev),
          jurisdiction_type: "State",
          jurisdiction_id: state.id,
          governance_type_id: court.id,
          branch: :judicial,
          description: "The court of last resort of #{state.name}.",
          meeting_schedule: "Scheduled terms",
          is_active: true,
          established_date: case abbrev
                           when "CA" then Date.new(1849, 12, 20)
                           when "NY" then Date.new(1847, 7, 5)
                           when "TX" then Date.new(1845, 12, 29)
                           when "FL" then Date.new(1845, 3, 3)
                           else Date.new(1850, 1, 1)
                           end
        }
      end
      
      if executive
        governing_bodies << {
          name: "Office of the Governor of #{state.name}",
          jurisdiction_type: "State",
          jurisdiction_id: state.id,
          governance_type_id: executive.id,
          branch: :executive,
          description: "The executive institution of #{state.name} state government, headed by the Governor.",
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
      next unless city && council
      
      governing_bodies << {
        name: "#{city.name} City Council",
        jurisdiction_type: "City",
        jurisdiction_id: city.id,
        governance_type_id: council.id,
        branch: :legislative,
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
      if executive
        governing_bodies << {
          name: "#{county} County Executive",
          jurisdiction_type: "City", # Using city as proxy for county
          jurisdiction_id: city.id,
          governance_type_id: executive.id,
          branch: :executive,
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
      next unless city && board
      
      governing_bodies << {
        name: "#{name} Board",
        jurisdiction_type: "City",
        jurisdiction_id: city.id,
        governance_type_id: board.id,
        branch: nil,
        description: "The governing board of #{name}, responsible for educational policy, budget oversight, and superintendent selection.",
        meeting_schedule: "Monthly",
        is_active: true,
        established_date: Date.new(1920, 1, 1)
      }
    end
    
    # Special Districts
    if board && san_francisco
      governing_bodies << {
        name: "San Francisco Bay Area Rapid Transit District Board",
        jurisdiction_type: "City",
        jurisdiction_id: san_francisco.id,
        governance_type_id: board.id,
        branch: nil,
        description: "The governing board of BART, responsible for transit policy, fare setting, and system expansion decisions.",
        meeting_schedule: "Bi-weekly",
        is_active: true,
        established_date: Date.new(1957, 5, 21)
      }
    end
    
    if board && los_angeles
      governing_bodies << {
        name: "Metropolitan Water District of Southern California Board",
        jurisdiction_type: "City",
        jurisdiction_id: los_angeles.id,
        governance_type_id: board.id,
        branch: nil,
        description: "The governing board responsible for water supply management and infrastructure for Southern California region.",
        meeting_schedule: "Monthly",
        is_active: true,
        established_date: Date.new(1928, 12, 6)
      }
    end
    
    # Create the governing bodies
    governing_bodies.each do |gb_attrs|
      chambers = gb_attrs.delete(:chambers)
      governing_body = GoverningBody.find_or_initialize_by(
        name: gb_attrs[:name],
        jurisdiction_type: gb_attrs[:jurisdiction_type],
        jurisdiction_id: gb_attrs[:jurisdiction_id]
      )
      governing_body.assign_attributes(gb_attrs)

      if governing_body.save
        seed_chambers(governing_body, chambers)
        print "."
      else
        puts "\n❌ Failed to create governing body: #{gb_attrs[:name]}"
        puts "   Errors: #{governing_body.errors.full_messages.join(', ')}"
      end
    end
    
    puts " #{GoverningBody.count} governing bodies"
  end

  def self.lower_house_name(abbrev)
    %w[CA NY].include?(abbrev) ? "Assembly" : "House of Representatives"
  end

  def self.court_name(state, abbrev)
    return "New York Court of Appeals" if abbrev == "NY"

    "Supreme Court of #{state.name}"
  end

  def self.seed_chambers(governing_body, chambers)
    return if chambers.blank?

    chambers.each do |attrs|
      chamber = governing_body.chambers.find_or_initialize_by(name: attrs[:name])
      chamber.description = attrs[:description]
      chamber.save!
    end
  end
end