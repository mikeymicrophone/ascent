class VoterElectionBaselineSeeder
  def self.seed
    # Create baselines for voters in elections they have ratings for
    create_baselines_for_existing_ratings
    
    puts "Seeded #{VoterElectionBaseline.count} voter election baselines"
  end
  
  private
  
  def self.create_baselines_for_existing_ratings
    # Get all unique voter-election combinations from existing ratings
    voter_election_combinations = Rating.joins(:candidacy)
                                        .distinct
                                        .pluck(:voter_id, "candidacies.election_id")
    
    voter_election_combinations.each do |voter_id, election_id|
      voter = Voter.find(voter_id)
      election = Election.find(election_id)
      
      # Skip if baseline already exists
      next if VoterElectionBaseline.exists?(voter: voter, election: election)
      
      # Create a realistic baseline for this voter-election combination
      baseline = generate_realistic_baseline(voter, election)
      
      VoterElectionBaseline.create!(
        voter: voter,
        election: election,
        baseline: baseline
      )
    end
  end
  
  def self.generate_realistic_baseline(voter, election)
    # Generate baselines that vary by election type and voter characteristics
    base_baseline = case election.office.position.title
    when "President"
      # Presidential elections tend to have higher engagement, moderate baselines
      rand(250..350)
    when "Governor"
      # State elections, slightly lower engagement
      rand(220..320)
    when "Mayor"
      # Local elections, more varied baselines
      rand(200..400)
    else
      # Default for other positions
      rand(200..350)
    end
    
    # Add some personal variance based on voter characteristics
    if voter.is_verified
      # Verified voters might be more engaged, slightly higher baselines
      base_baseline += rand(0..30)
    end
    
    # Add random variance to make it realistic
    variance = rand(-50..50)
    final_baseline = (base_baseline + variance).clamp(0, 500)
    
    final_baseline
  end
end