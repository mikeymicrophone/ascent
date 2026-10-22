class CandidacySeeder
  def self.seed
    # Never attach fictional people to a source-backed election.
    create_mock_election_candidacies
    create_mock_local_candidacies
    
    puts "Seeded #{Candidacy.count} candidacies"
  end
  
  private
  
  def self.create_mock_election_candidacies
    # Find the mock presidential race
    mock_races = Race.mock.joins(office: :position).where(positions: { title: "President" }).limit(1)
    
    mock_races.each do |race|
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
        
        candidacy = Candidacy.find_or_create_by(
          person: person,
          race: race
        ) do |candidacy|
          candidacy.status = "active"
          candidacy.announcement_date = Date.new(2024, 1, 15)
          candidacy.platform_summary = candidate_data[:platform]
        end
        candidacy.ballot_lines.find_or_create_by!(label: candidate_data[:party]) do |line|
          line.kind = "party"
          line.position = 1
        end
      end
    end
  end

  # One fictional candidate for each mock local race, chosen to fit their biography.
  MOCK_LOCAL_CANDIDATES = {
    "Mayor" => "michael.brown@example.com",
    "Council Member" => "sarah.williams@example.com",
    "Sheriff" => "daniel.reyes@example.com",
    "School Board" => "grace.nakamura@example.com",
    "County Commissioner" => "alexandra.chen@example.com",
    "District Attorney" => "david.thompson@example.com",
    "State Representative" => "marcus.rodriguez@example.com",
    "State Senator" => "lisa.chang@example.com",
    "Governor" => "patricia.okafor@example.com"
  }.freeze

  def self.create_mock_local_candidacies
    MOCK_LOCAL_CANDIDATES.each do |position_title, email|
      race = Race.mock.joins(office: :position).find_by(positions: { title: position_title })
      person = Person.find_by(email: email)
      next unless race && person

      Candidacy.find_or_create_by(person: person, race: race) do |candidacy|
        candidacy.status = "active"
        candidacy.announcement_date = Date.new(2024, 3, 4)
        candidacy.platform_summary = person.bio
      end
    end
  end
end
