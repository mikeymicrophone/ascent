class Views::Partials::RacePartial < Views::ApplicationView
  def initialize(race:)
    @race = race
  end

  def view_template(&)
    div(id: dom_id(@race), class: "race-partial") do
      div(class: "partial-header") do
        h3(class: "partial-title") { @race.office.name }
        div(class: "header-indicators") do
          span(class: "status-indicator status-#{@race.status}") { @race.status.capitalize }
          if @race.election.is_mock
            span(class: "status-indicator status-mock") { "Mock Election" }
          end
          if @race.election.is_historical
            span(class: "status-indicator status-historical") { "Historical" }
          end
        end
      end

      div(class: "partial-content") do
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Election" }
            link_to @race.election.name, @race.election, class: "link election info-value"
          end
          div(class: "info-item") do
            span(class: "info-label") { "Office" }
            link_to @race.office.name, @race.office, class: "link office info-value"
          end
          div(class: "info-item") do
            span(class: "info-label") { "Election Date" }
            span(class: "info-value") { @race.election_date.to_fs(:display) }
          end
        end

        if @race.description.present?
          div(class: "content-section") do
            div(class: "content-description") { simple_format(@race.description) }
          end
        end
      end

      div(class: "expandable-sections") do
        expandable(@race, :candidacies, title: "Candidates") do |candidacies|
          div(class: "expandable-grid") do
            ItemPreview(@race, :candidacies, 5) do |candidacy|
              div(class: "candidate-preview-item") do
                link_to candidacy.name, candidacy, class: "link candidate"
                if candidacy.ballot_summary.present?
                  span(class: "candidate-party") { " (#{candidacy.ballot_summary})" }
                end
              end
            end
          end
        end

        if @race.status == "completed" && @race.candidacies.any?
          expandable(@race, @race.candidacies, title: "Results") do |candidacies|
            div(class: "results-container") do
              results_preview(@race)
            end
          end
        end
      end

      if @race.status == "active"
        div(class: "election-vote-action") do
          link_to "Vote", mountain_path(@race, voter_id: current_voter&.id), class: "btn-primary"
        end
      end
    end
  end

  def results_preview(race = @race)
    div(class: "results-preview") do
      results = race.approval_results
      if results.any?
        div(class: "results-summary") do
          span(class: "results-title") { "Approval Voting Results:" }
        end

        results.first(3).each_with_index do |(candidacy, vote_count), index|
          candidate = candidacy.person
          div(class: "result-preview-item") do
            span(class: "result-rank") { "#{index + 1}." }
            whitespace
            link_to candidate.name, candidate, class: "link candidate"
            span(class: "result-votes") { " - #{vote_count} votes" }
          end
        end

        div(class: "results-view-all") do
          link_to "View full results", race, class: "link view-all"
        end
      else
        div(class: "no-results") do
          span { "No results available yet" }
        end
      end
    end
  end
end
