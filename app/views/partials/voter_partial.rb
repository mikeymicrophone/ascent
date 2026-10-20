class Views::Partials::VoterPartial < Views::ApplicationView
  def initialize(voter:)
    @voter = voter
  end

  def view_template(&)
    div(id: dom_id(@voter), class: "voter-partial") do
      h3 { @voter.first_name }
      div do
        span { "Last name:" }
        whitespace
        span { @voter.last_name }
      end
      div do
        span { "Birth date:" }
        whitespace
        span { @voter.birth_date.strftime("%B %d, %Y") }
      end
      div do
        span { "Is verified:" }
        whitespace
        span { @voter.is_verified.to_s }
      end
      
      # Voting Activity expandable section  
      if @voter.ratings.any? || @voter.voter_race_baselines.any?
        expandable(@voter, participated_races(@voter), title: "Voting Activity") do |activity|
          voting_activity_preview(@voter)
        end
      end
    end
  end

  def voting_activity_preview(voter = @voter)
    div(class: "voting-activity-preview") do
      # Group activity by races
      participated_races = participated_races(voter)
      
      # Show first 5 races, sorted by date (most recent first)
      participated_races.first(5).each do |race_data|
        div(class: "voting-activity-item") do
          voting_activity_item(race_data)
        end
      end
      
      # Show "View All" link if there are more than 5 races
      if participated_races.count > 5
        div(class: "voting-activity-view-all") do
          link_to "View all #{participated_races.count} races", 
                  ratings_path(voter_id: voter.id), 
                  class: "link view-all"
        end
      end
    end
  end

  def voting_activity_item(race_data)
    race = race_data[:race]
    baseline = race_data[:baseline]
    ratings_count = race_data[:ratings_count]
    
    div(class: "voting-activity-header") do
      link_to race.election.name, race, class: "link election"
      span(class: "voting-office") { " for #{race.office.position.title}" }
    end
    
    div(class: "voting-activity-details") do
      # Election date
      span(class: "election-date") { race.election_date.strftime("%B %d, %Y") }
      
      # Voting participation info
      span(class: "voting-participation") { "#{ratings_count} ratings" }
      
      # Baseline info if set
      if baseline
        span(class: "voting-baseline") { "Baseline: #{baseline.baseline}" }
      end
      
      # Status indicator
      status = determine_voting_status(race_data)
      span(class: "status-indicator status-#{status}") { status.capitalize }
    end
  end

  def voting_activity_count(voter = @voter)
    voter.voter_race_baselines.count + 
    voter.ratings.joins(:candidacy).select('candidacies.race_id').distinct.count
  end

  def participated_races(voter = @voter)
    # Use the with_voting_activity scope to pre-load all necessary associations
    voter_with_activity = Voter.with_voting_activity.find(voter.id)
    
    # Get races where voter has set baselines or made ratings
    baseline_races = voter_with_activity.voter_race_baselines.map(&:race)
    rating_races = voter_with_activity.ratings.map { |r| r.candidacy.race }.uniq
    
    all_races = (baseline_races + rating_races).uniq
    
    # Build race data with associated voting info
    all_races.map do |race|
      baseline = voter_with_activity.voter_race_baselines.find { |b| b.race_id == race.id }
      ratings_count = voter_with_activity.ratings.count { |r| r.candidacy.race_id == race.id }
      
      {
        race: race,
        baseline: baseline,
        ratings_count: ratings_count
      }
    end.sort_by { |data| data[:race].election_date }.reverse
  end

  private

  def determine_voting_status(race_data)
    race = race_data[:race]
    baseline = race_data[:baseline]
    ratings_count = race_data[:ratings_count]
    
    return "upcoming" if race.status == "upcoming"
    return "active" if race.status == "active"
    
    # For completed races
    if baseline && ratings_count > 0
      "participated"
    elsif ratings_count > 0
      "partial" # Rated but no baseline set
    elsif baseline
      "baseline-only" # Set baseline but no ratings
    else
      "registered" # Somehow involved but minimal participation
    end
  end
end