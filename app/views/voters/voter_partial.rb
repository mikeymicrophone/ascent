class Views::Voters::VoterPartial < Views::ApplicationView
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
      if @voter.ratings.any? || @voter.voter_election_baselines.any?
        expandable_voting_activity
      end
    end
  end

  def expandable_voting_activity(voter = @voter)
    Views::Components::ExpandableSection(
      title: "Voting Activity",
      count: voting_activity_count(voter)
    ) do
      voting_activity_preview(voter)
    end
  end

  def voting_activity_preview(voter = @voter)
    div(class: "voting-activity-preview") do
      # Group activity by elections
      participated_elections = participated_elections(voter)
      
      # Show first 5 elections, sorted by date (most recent first)
      participated_elections.first(5).each do |election_data|
        div(class: "voting-activity-item") do
          voting_activity_item(election_data)
        end
      end
      
      # Show "View All" link if there are more than 5 elections
      if participated_elections.count > 5
        div(class: "voting-activity-view-all") do
          link_to "View all #{participated_elections.count} elections", 
                  ratings_path(voter_id: voter.id), 
                  class: "link view-all"
        end
      end
    end
  end

  def voting_activity_item(election_data)
    election = election_data[:election]
    baseline = election_data[:baseline]
    ratings_count = election_data[:ratings_count]
    
    div(class: "voting-activity-header") do
      link_to election.name, election, class: "link election"
      span(class: "voting-office") { " for #{election.office.position.title}" }
    end
    
    div(class: "voting-activity-details") do
      # Election date
      span(class: "election-date") { election.election_date.strftime("%B %d, %Y") }
      
      # Voting participation info
      span(class: "voting-participation") { "#{ratings_count} ratings" }
      
      # Baseline info if set
      if baseline
        span(class: "voting-baseline") { "Baseline: #{baseline.baseline}" }
      end
      
      # Status indicator
      status = determine_voting_status(election_data)
      span(class: "status-indicator status-#{status}") { status.capitalize }
    end
  end

  def voting_activity_count(voter = @voter)
    voter.voter_election_baselines.count + 
    voter.ratings.joins(:candidacy).select('candidacies.election_id').distinct.count
  end

  def participated_elections(voter = @voter)
    # Use the with_voting_activity scope to pre-load all necessary associations
    voter_with_activity = Voter.with_voting_activity.find(voter.id)
    
    # Get elections where voter has set baselines or made ratings
    baseline_elections = voter_with_activity.voter_election_baselines.map(&:election)
    rating_elections = voter_with_activity.ratings.map { |r| r.candidacy.election }.uniq
    
    all_elections = (baseline_elections + rating_elections).uniq
    
    # Build election data with associated voting info
    all_elections.map do |election|
      baseline = voter_with_activity.voter_election_baselines.find { |b| b.election_id == election.id }
      ratings_count = voter_with_activity.ratings.count { |r| r.candidacy.election_id == election.id }
      
      {
        election: election,
        baseline: baseline,
        ratings_count: ratings_count
      }
    end.sort_by { |data| data[:election].election_date }.reverse
  end

  private

  def determine_voting_status(election_data)
    election = election_data[:election]
    baseline = election_data[:baseline]
    ratings_count = election_data[:ratings_count]
    
    return "upcoming" if election.status == "upcoming"
    return "active" if election.status == "active"
    
    # For completed elections
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