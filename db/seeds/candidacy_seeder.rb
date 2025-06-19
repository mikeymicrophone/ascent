class CandidacySeeder
  def self.seed
    # Create candidacies for various elections
    create_presidential_candidacies
    create_gubernatorial_candidacies
    create_mayoral_candidacies
    create_mock_election_candidacies
    
    puts "Seeded #{Candidacy.count} candidacies"
  end
  
  private
  
  def self.create_presidential_candidacies
    # Find 2024 presidential election
    presidential_election = Election.joins(:office, :year)
                                   .joins(office: :position)
                                   .where(positions: { title: "President" })
                                   .where(years: { year: 2024 })
                                   .where(is_mock: false)
                                   .first
    
    return unless presidential_election
    
    # Create candidacies for some people
    candidates = [
      { person_email: "marcus.rodriguez@example.com", party: "Democratic", platform: "Focused on economic equality, healthcare access, and climate action." },
      { person_email: "david.thompson@example.com", party: "Republican", platform: "Committed to constitutional principles, fiscal responsibility, and strong national defense." },
      { person_email: "sarah.williams@example.com", party: "Independent", platform: "Advocating for political reform, government transparency, and bipartisan solutions." }
    ]
    
    candidates.each do |candidate_data|
      person = Person.find_by(email: candidate_data[:person_email])
      next unless person
      
      Candidacy.find_or_create_by(
        person: person,
        election: presidential_election
      ) do |candidacy|
        candidacy.status = "active"
        candidacy.announcement_date = Date.new(2023, 6, 15)
        candidacy.party_affiliation = candidate_data[:party]
        candidacy.platform_summary = candidate_data[:platform]
      end
    end
  end
  
  def self.create_gubernatorial_candidacies
    # Find some gubernatorial elections
    gubernatorial_elections = Election.joins(:office)
                                     .joins(office: :position)
                                     .where(positions: { title: "Governor" })
                                     .limit(2)
    
    people = Person.limit(4).to_a
    
    gubernatorial_elections.each_with_index do |election, election_index|
      # Create 2 candidacies per election
      election_people = people.slice(election_index * 2, 2)
      
      election_people.each_with_index do |person, person_index|
        party = person_index.even? ? "Democratic" : "Republican"
        
        Candidacy.find_or_create_by(
          person: person,
          election: election
        ) do |candidacy|
          candidacy.status = "active"
          candidacy.announcement_date = Date.new(2023, 8, 1)
          candidacy.party_affiliation = party
          candidacy.platform_summary = "Committed to serving the people of #{election.office.jurisdiction.name} with integrity and vision."
        end
      end
    end
  end
  
  def self.create_mayoral_candidacies
    # Find some mayoral elections
    mayoral_elections = Election.joins(:office)
                               .joins(office: :position)
                               .where(positions: { title: "Mayor" })
                               .limit(2)
    
    people = Person.limit(4).to_a
    
    mayoral_elections.each_with_index do |election, election_index|
      # Create 2 candidacies per election
      election_people = people.slice(election_index * 2, 2)
      
      election_people.each do |person|
        Candidacy.find_or_create_by(
          person: person,
          election: election
        ) do |candidacy|
          candidacy.status = "active"
          candidacy.announcement_date = Date.new(2023, 9, 15)
          candidacy.party_affiliation = "Nonpartisan"
          candidacy.platform_summary = "Dedicated to improving quality of life, economic development, and community engagement in #{election.office.jurisdiction.name}."
        end
      end
    end
  end
  
  def self.create_mock_election_candidacies
    # Find mock elections
    mock_elections = Election.where(is_mock: true).limit(1)
    
    mock_elections.each do |election|
      # Create several candidacies for educational purposes
      mock_candidates = [
        { person_email: "jennifer.kim@example.com", party: "Progressive", platform: "Technology-forward governance with focus on digital equity and innovation." },
        { person_email: "robert.johnson@example.com", party: "Conservative", platform: "Fiscal responsibility, strong defense, and traditional values." },
        { person_email: "maria.garcia@example.com", party: "Social Democratic", platform: "Social justice, community empowerment, and inclusive economic policy." },
        { person_email: "james.anderson@example.com", party: "Labor", platform: "Workers' rights, union protection, and manufacturing job creation." }
      ]
      
      mock_candidates.each do |candidate_data|
        person = Person.find_by(email: candidate_data[:person_email])
        next unless person
        
        Candidacy.find_or_create_by(
          person: person,
          election: election
        ) do |candidacy|
          candidacy.status = "active"
          candidacy.announcement_date = Date.new(2024, 1, 15)
          candidacy.party_affiliation = candidate_data[:party]
          candidacy.platform_summary = candidate_data[:platform]
        end
      end
    end
  end
end