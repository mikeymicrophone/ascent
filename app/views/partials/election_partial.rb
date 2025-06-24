class Views::Partials::ElectionPartial < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    div(id: dom_id(@election), class: "election-partial") do
      # Header with office name, status, and type indicators
      div(class: "partial-header") do
        h3(class: "partial-title") { @election.office.name }
        div(class: "header-indicators") do
          span(class: "status-indicator status-#{@election.status}") { @election.status.capitalize }
          if @election.is_mock
            span(class: "status-indicator status-mock") { "Mock Election" }
          end
          if @election.is_historical
            span(class: "status-indicator status-historical") { "Historical" }
          end
        end
      end
      
      # Election metadata in organized layout
      div(class: "partial-content") do
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Year" }
            link_to @election.year.name, @election.year, class: "link year info-value"
          end
          div(class: "info-item") do
            span(class: "info-label") { "Election Date" }
            span(class: "info-value") { @election.election_date.strftime("%B %d, %Y") }
          end
        end
        
        # Description with proper typography
        if @election.description.present?
          div(class: "content-section") do
            div(class: "content-description") { simple_format(@election.description) }
          end
        end
      end
      
      # Expandable sections with improved layout
      div(class: "expandable-sections") do
        expandable(@election, :candidacies, title: "Candidates") do |candidacies|
          div(class: "expandable-grid") do
            ItemPreview(@election, :candidacies, 5) do |candidate|
              div(class: "candidate-preview-item") do
                link_to candidate.name, candidate, class: "link candidate"
                if candidate.respond_to?(:party_affiliation) && candidate.party_affiliation.present?
                  span(class: "candidate-party") { " (#{candidate.party_affiliation})" }
                end
              end
            end
          end
        end
        
        # Results expandable section (only for completed elections)
        if @election.status == 'completed' && @election.candidates.any?
          expandable(@election, @election.candidacies, title: "Results") do |candidacies|
            div(class: "results-container") do
              results_preview(@election)
            end
          end
        end
      end
    end
  end

  def results_preview(election = @election)
    div(class: "results-preview") do
      results = election.approval_results
      if results.any?
        div(class: "results-summary") do
          span(class: "results-title") { "Approval Voting Results:" }
        end
        
        # Show top 3 results
        results.first(3).each_with_index do |result, index|
          candidacy, vote_count = result
          candidate = candidacy.person
          div(class: "result-preview-item") do
            span(class: "result-rank") { "#{index + 1}." }
            whitespace
            link_to candidate.name, candidate, class: "link candidate"
            span(class: "result-votes") { " - #{vote_count} votes" }
          end
        end
        
        # Show "View Full Results" link
        div(class: "results-view-all") do
          link_to "View full results", election, class: "link view-all"
        end
      else
        div(class: "no-results") do
          span { "No results available yet" }
        end
      end
    end
  end
end