class Views::Partials::OfficePartial < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    div(id: dom_id(@office), class: "office-partial") do
      h3 { @office.position.title }
      div do
        span { "Jurisdiction:" }
        whitespace
        jurisdiction_link @office.jurisdiction
      end
      if @office.governing_body
        div do
          span { "Governing body:" }
          whitespace
          link_to @office.governing_body.name, @office.governing_body, class: "link governing_body"
        end
      end
      if @office.chamber
        div do
          span { "Chamber:" }
          whitespace
          span { @office.chamber.name }
        end
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
      
      current_office_holder
      race_history
    end
  end

  def current_office_holder(office = @office)
    current_winner = office.current_office_holder
    return unless current_winner
    
    div(class: "current-holder-section") do
      h4 { "Current Office Holder" }
      div(class: "current-holder-info") do
        link_to current_winner.person.name, current_winner.person, class: "link current-holder-name"
        span(class: "current-holder-details") do
          whitespace
          span { "(" }
          if current_winner.ballot_labels.present?
            span(class: "current-holder-party") { current_winner.ballot_labels }
            span { ", " }
          end
          span { "elected #{current_winner.race.year.year}" }
          span { ")" }
        end
      end
    end
  end

  def race_history(office = @office)
    expandable(office, :races, title: "Election History & Timeline") do |races|
      div(class: "election-timeline") do
        office.races.recent.includes(:election).limit(3).each do |race|
          race_details(race)
        end
        
        if office.races.count > 3
          div(class: "elections-view-all") do
            link_to "View all #{office.races.count} races", [office, :races], class: "link view-all"
          end
        end
      end
    end
  end

  def race_details(race)
    div(class: "election-timeline-item") do
      div(class: "election-header") do
        div(class: "election-main-info") do
          link_to race.election.name, race, class: "link election-name"
          div(class: "election-meta") do
            span(class: "election-date") { race.election_date.strftime("%B %d, %Y") }
            span(class: "election-status") do
              whitespace
              span { "•" }
              whitespace
              span(class: "status-indicator status-#{race.status}") { race.status.capitalize }
            end
          end
        end
      end
      
      if race.status == "completed"
        race_results(race)
      elsif race.status == "upcoming"
        race_schedule(race)
      end
      
      voter_turnout_stats(race)
    end
  end

  def race_results(race)
    results = race.approval_results
    return if results.empty?
    
    div(class: "election-results") do
      h5 { "Results" }
      div(class: "results-list") do
        results.take(3).each_with_index do |(candidacy, vote_count), index|
          div(class: "result-item") do
            span(class: "result-rank") { "#{index + 1}." }
            whitespace
            link_to candidacy.person.name, candidacy.person, class: "link candidate-name"
            if candidacy.ballot_labels.present?
              span(class: "candidate-party") { " (#{candidacy.ballot_labels})" }
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
          link_to "View full results", race, class: "link"
        end
      end
    end
  end

  def race_schedule(race)
    div(class: "election-schedule") do
      span(class: "schedule-label") { "Scheduled:" }
      whitespace
      span(class: "schedule-date") { race.election_date.strftime("%B %d, %Y") }
      
      days_until = (race.election_date - Date.current).to_i
      if days_until > 0
        span(class: "days-until") { " (#{days_until} days away)" }
      elsif days_until == 0
        span(class: "election-today") { " (Today!)" }
      end
    end
  end

  def voter_turnout_stats(race)
    return unless race.status == "completed" && race.voter_race_baselines.any?
    
    summary = race.results_summary
    
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