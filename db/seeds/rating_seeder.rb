class RatingSeeder
  def self.seed
    # Create realistic rating distributions for voters
    create_presidential_ratings
    create_gubernatorial_ratings
    create_mayoral_ratings
    create_archived_ratings
    
    puts "Seeded #{Rating.count} ratings and #{RatingArchive.count} archived ratings"
  end
  
  private
  
  def self.create_presidential_ratings
    # Find 2024 presidential election candidacies
    presidential_candidacies = Candidacy.joins(election: { office: :position })
                                       .where(positions: { title: "President" })
                                       .where(elections: { is_mock: false })
    
    return if presidential_candidacies.empty?
    
    # Get voters who are eligible for presidential elections (US voters)
    us_country = Country.find_by(name: "United States")
    us_states = us_country.states if us_country
    us_cities = City.joins(:state).where(states: { country: us_country }) if us_country
    
    us_voters = Voter.joins(:registrations)
                     .where(registrations: { status: "active" })
                     .where(
                       "(registrations.jurisdiction_type = 'Country' AND registrations.jurisdiction_id = ?) OR " +
                       "(registrations.jurisdiction_type = 'State' AND registrations.jurisdiction_id IN (?)) OR " +
                       "(registrations.jurisdiction_type = 'City' AND registrations.jurisdiction_id IN (?))",
                       us_country&.id || 0,
                       us_states&.pluck(:id) || [],
                       us_cities&.pluck(:id) || []
                     )
                     .distinct
                     .limit(8)
    
    us_voters.each do |voter|
      # Set a baseline for this voter (varies by voter preference)
      baseline = rand(200..350)
      
      presidential_candidacies.each do |candidacy|
        next unless voter.eligible_for_election?(candidacy.election)
        
        # Create realistic rating distribution
        rating = generate_realistic_rating(candidacy, baseline)
        
        Rating.find_or_create_by(
          voter: voter,
          candidacy: candidacy
        ) do |r|
          r.rating = rating
          r.baseline = baseline
        end
      end
    end
  end
  
  def self.create_gubernatorial_ratings
    # Find some gubernatorial elections
    gubernatorial_candidacies = Candidacy.joins(election: { office: :position })
                                        .where(positions: { title: "Governor" })
                                        .limit(8)
    
    gubernatorial_candidacies.each do |candidacy|
      # Find voters eligible for this specific election
      eligible_voters = find_eligible_voters_for_candidacy(candidacy).limit(3)
      
      eligible_voters.each do |voter|
        baseline = rand(220..320)
        rating = generate_realistic_rating(candidacy, baseline)
        
        Rating.find_or_create_by(
          voter: voter,
          candidacy: candidacy
        ) do |r|
          r.rating = rating
          r.baseline = baseline
        end
      end
    end
  end
  
  def self.create_mayoral_ratings
    # Find mayoral elections
    mayoral_candidacies = Candidacy.joins(election: { office: :position })
                                  .where(positions: { title: "Mayor" })
                                  .limit(6)
    
    mayoral_candidacies.each do |candidacy|
      # Find voters eligible for this specific election
      eligible_voters = find_eligible_voters_for_candidacy(candidacy).limit(2)
      
      eligible_voters.each do |voter|
        baseline = rand(250..400)
        rating = generate_realistic_rating(candidacy, baseline)
        
        Rating.find_or_create_by(
          voter: voter,
          candidacy: candidacy
        ) do |r|
          r.rating = rating
          r.baseline = baseline
        end
      end
    end
  end
  
  def self.create_archived_ratings
    # Create some rating changes to demonstrate archiving
    ratings_to_update = Rating.limit(5)
    
    ratings_to_update.each do |rating|
      # Update rating to trigger archiving
      old_rating = rating.rating
      old_baseline = rating.baseline
      
      # Simulate rating change over time
      new_rating = [old_rating + rand(-50..50), 0].max.clamp(0, 500)
      new_baseline = [old_baseline + rand(-20..20), 0].max.clamp(0, 500)
      
      rating.update!(
        rating: new_rating,
        baseline: new_baseline
      )
    end
  end
  
  def self.find_eligible_voters_for_candidacy(candidacy)
    office_jurisdiction = candidacy.election.office.jurisdiction
    
    case office_jurisdiction
    when Country
      # Country elections: voters registered in that country (via states/cities)
      country_states = office_jurisdiction.states
      country_cities = City.joins(:state).where(states: { country: office_jurisdiction })
      
      Voter.joins(:registrations)
           .where(registrations: { status: "active" })
           .where(
             "(registrations.jurisdiction_type = 'Country' AND registrations.jurisdiction_id = ?) OR " +
             "(registrations.jurisdiction_type = 'State' AND registrations.jurisdiction_id IN (?)) OR " +
             "(registrations.jurisdiction_type = 'City' AND registrations.jurisdiction_id IN (?))",
             office_jurisdiction.id,
             country_states.pluck(:id),
             country_cities.pluck(:id)
           )
           .distinct
    when State
      # State elections: voters registered in that state (directly or via cities)
      Voter.joins(:registrations)
           .where(registrations: { status: "active" })
           .where(
             "(registrations.jurisdiction_type = 'State' AND registrations.jurisdiction_id = ?) OR " +
             "(registrations.jurisdiction_type = 'City' AND registrations.jurisdiction_id IN (?))",
             office_jurisdiction.id,
             office_jurisdiction.cities.pluck(:id)
           )
           .distinct
    when City
      # City elections: voters registered in that city
      Voter.joins(:registrations)
           .where(registrations: { status: "active" })
           .where(
             "registrations.jurisdiction_type = 'City' AND registrations.jurisdiction_id = ?",
             office_jurisdiction.id
           )
           .distinct
    else
      Voter.none
    end
  end
  
  def self.generate_realistic_rating(candidacy, baseline)
    # Generate realistic ratings based on party affiliation and baseline
    base_preference = case candidacy.party_affiliation&.downcase
    when "democratic"
      rand(180..450)
    when "republican"
      rand(150..420)
    when "independent"
      rand(200..380)
    when "progressive"
      rand(220..480)
    when "conservative"
      rand(120..380)
    else
      rand(100..400)
    end
    
    # Add some variance and ensure rating makes sense relative to baseline
    variance = rand(-80..80)
    final_rating = (base_preference + variance).clamp(0, 500)
    
    # Ensure some logical consistency with baseline
    if rand < 0.3 # 30% chance of rating being close to baseline
      final_rating = baseline + rand(-50..50)
    end
    
    final_rating.clamp(0, 500)
  end
end