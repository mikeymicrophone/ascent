class VoterRaceBaselineSeeder
  def self.seed
    # Create baselines for voters in races they have ratings for
    create_baselines_for_existing_ratings

    puts "Seeded #{VoterRaceBaseline.count} voter race baselines"
  end

  private

  def self.create_baselines_for_existing_ratings
    # Get all unique voter-race combinations from existing ratings
    voter_race_combinations = Rating.joins(:candidacy)
                                    .distinct
                                    .pluck(:voter_id, "candidacies.race_id")

    voter_race_combinations.each do |voter_id, race_id|
      voter = Voter.find(voter_id)
      race = Race.find(race_id)

      # Skip if baseline already exists
      next if VoterRaceBaseline.exists?(voter: voter, race: race)

      # Create a realistic baseline for this voter-race combination
      baseline = generate_realistic_baseline(voter, race)

      VoterRaceBaseline.create!(
        voter: voter,
        race: race,
        baseline: baseline
      )
    end
  end

  def self.generate_realistic_baseline(voter, race)
    # Generate baselines that vary by race type and voter characteristics
    base_baseline = case race.office.position.title
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
