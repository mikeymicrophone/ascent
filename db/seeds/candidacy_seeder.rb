class CandidacySeeder
  def self.seed
    # Never attach fictional people to a source-backed election.
    create_mock_election_candidacies
    
    puts "Seeded #{Candidacy.count} candidacies"
  end
  
  private
  
  def self.create_mock_election_candidacies
    # Find races in mock elections
    mock_races = Race.mock.limit(1)
    
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
end
