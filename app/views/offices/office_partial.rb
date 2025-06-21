class Views::Offices::OfficePartial < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    div(id: dom_id(@office), class: "office-partial") do
      h3 { @office.position.title }
      div do
        span { "Jurisdiction:" }
        whitespace
        link_to @office.jurisdiction.name, @office.jurisdiction, class: "link jurisdiction"
      end
      div do
        span { "Is active:" }
        whitespace
        span { @office.is_active.to_s }
      end
      div do
        span { "Notes:" }
        whitespace
        div(class: "mt-1") { simple_format(@office.notes) }
      end
      
      render_current_office_holder
      render_election_history
    end
  end

  private

  def render_current_office_holder
    current_winner = @office.current_office_holder
    return unless current_winner
    
    div(class: "current-holder-section") do
      h4 { "Current Office Holder" }
      div(class: "current-holder-info") do
        link_to current_winner.person.name, current_winner.person, class: "link current-holder-name"
        span(class: "current-holder-details") do
          whitespace
          span { "(" }
          if current_winner.party_affiliation.present?
            span(class: "current-holder-party") { current_winner.party_affiliation }
            span { ", " }
          end
          span { "elected #{current_winner.election.year.year}" }
          span { ")" }
        end
      end
    end
  end

  def render_election_history
    return unless @office.elections.any?
    
    Views::Components::ExpandableSection(
      title: "Election History & Timeline",
      count: @office.elections.count
    ) do
      div(class: "election-timeline") do
        # Use database ordering instead of Ruby sorting for better performance
        recent_elections = @office.elections.order(election_date: :desc).limit(3)
        
        recent_elections.each do |election|
          render_election_details(election)
        end
        
        if @office.elections.count > 3
          div(class: "elections-view-all") do
            link_to "View all #{@office.elections.count} elections", [@office, :elections], class: "link view-all"
          end
        end
      end
    end
  end

  def render_election_details(election)
    div(class: "election-timeline-item") do
      div(class: "election-header") do
        div(class: "election-main-info") do
          link_to election.name, election, class: "link election-name"
          div(class: "election-meta") do
            span(class: "election-date") { election.election_date.strftime("%B %d, %Y") }
            span(class: "election-status") do
              whitespace
              span { "•" }
              whitespace
              span(class: "status-indicator status-#{election.status}") { election.status.capitalize }
            end
          end
        end
      end
      
      if election.status == "completed"
        render_election_results(election)
      elsif election.status == "upcoming"
        render_election_schedule(election)
      end
      
      render_voter_turnout_stats(election)
    end
  end

  def render_election_results(election)
    results = election.approval_results
    return if results.empty?
    
    div(class: "election-results") do
      h5 { "Results" }
      div(class: "results-list") do
        results.take(3).each_with_index do |(candidacy, vote_count), index|
          div(class: "result-item") do
            span(class: "result-rank") { "#{index + 1}." }
            whitespace
            link_to candidacy.person.name, candidacy.person, class: "link candidate-name"
            if candidacy.party_affiliation.present?
              span(class: "candidate-party") { " (#{candidacy.party_affiliation})" }
            end
            span(class: "vote-count") { " - #{vote_count} votes" }
            if index == 0
              span(class: "winner-indicator") { " 👑" }
            end
          end
        end
      end
      
      if results.count > 3
        div(class: "more-results") do
          link_to "View full results", election, class: "link"
        end
      end
    end
  end

  def render_election_schedule(election)
    div(class: "election-schedule") do
      span(class: "schedule-label") { "Scheduled:" }
      whitespace
      span(class: "schedule-date") { election.election_date.strftime("%B %d, %Y") }
      
      days_until = (election.election_date - Date.current).to_i
      if days_until > 0
        span(class: "days-until") { " (#{days_until} days away)" }
      elsif days_until == 0
        span(class: "election-today") { " (Today!)" }
      end
    end
  end

  def render_voter_turnout_stats(election)
    return unless election.status == "completed" && election.voter_election_baselines.any?
    
    summary = election.results_summary
    
    div(class: "turnout-stats") do
      h6 { "Voter Participation" }
      div(class: "stats-grid") do
        div(class: "stat-item") do
          span(class: "stat-label") { "Registered Voters:" }
          whitespace
          span(class: "stat-value") { summary[:total_registered_voters] }
        end
        div(class: "stat-item") do
          span(class: "stat-label") { "Total Approvals:" }
          whitespace
          span(class: "stat-value") { summary[:total_approval_votes] }
        end
        div(class: "stat-item") do
          span(class: "stat-label") { "Avg Approvals/Voter:" }
          whitespace
          span(class: "stat-value") { summary[:average_approvals_per_voter] }
        end
      end
    end
  end

end