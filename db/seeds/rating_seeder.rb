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
    rate_candidacies(simulated_candidacies_for("President"), voters_per_candidacy: 8)
  end

  def self.create_gubernatorial_ratings
    rate_candidacies(simulated_candidacies_for("Governor").limit(8), voters_per_candidacy: 3)
  end

  def self.create_mayoral_ratings
    rate_candidacies(simulated_candidacies_for("Mayor").limit(6), voters_per_candidacy: 2)
  end

  # Fictional voters only rate candidacies in mock elections, never real candidates.
  def self.simulated_candidacies_for(position_title)
    Candidacy.joins(race: [ :election, { office: :position } ])
             .merge(Election.mock)
             .where(positions: { title: position_title })
  end

  def self.rate_candidacies(candidacies, voters_per_candidacy:)
    candidacies.each do |candidacy|
      find_eligible_voters_for_candidacy(candidacy).limit(voters_per_candidacy).each do |voter|
        Rating.find_or_create_by(
          voter: voter,
          candidacy: candidacy
        ) do |r|
          r.rating = generate_realistic_rating(candidacy)
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

      # Simulate rating change over time
      new_rating = [ old_rating + rand(-50..50), 0 ].max.clamp(0, 500)

      rating.update!(rating: new_rating)
    end
  end

  def self.find_eligible_voters_for_candidacy(candidacy)
    # Voters with an active residence in the office's jurisdiction or any jurisdiction nested within it
    Voter.joins(:residences)
         .where(residences: { status: "active", jurisdiction_id: candidacy.office.jurisdiction.self_and_descendants.select(:id) })
         .distinct
  end

  def self.generate_realistic_rating(candidacy)
    # Generate realistic ratings based on party affiliation and baseline
    base_preference = case candidacy.ballot_lines.first&.label&.downcase
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

    # Add some variance to make ratings more realistic
    variance = rand(-80..80)
    final_rating = (base_preference + variance).clamp(0, 500)

    final_rating
  end
end
