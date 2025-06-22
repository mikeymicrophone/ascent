class Views::Elections::ElectionPartial < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    div(id: dom_id(@election), class: "election-partial") do
      h3 { @election.office.name }
      div do
        span { "Year:" }
        whitespace
        link_to @election.year.name, @election.year, class: "link year"
      end
      div do
        span { "Election date:" }
        whitespace
        span { @election.election_date.strftime("%B %d, %Y") }
      end
      div do
        span { "Status:" }
        whitespace
        span(class: "status-indicator status-#{@election.status}") { @election.status.capitalize }
      end
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@election.description) }
      end
      div do
        span { "Is mock:" }
        whitespace
        span { @election.is_mock.to_s }
      end
      div do
        span { "Is historical:" }
        whitespace
        span { @election.is_historical.to_s }
      end
      
      # Candidates expandable section
      expandable(@election, :candidacies, title: "Candidates") do |candidacies|
        ItemPreview(@election, :candidacies, 5) do |candidate|
          link_to candidate.name, candidate, class: "link candidate"
          if candidate.respond_to?(:party_affiliation) && candidate.party_affiliation.present?
            span(class: "candidate-party") { " (#{candidate.party_affiliation})" }
          end
        end
      end
      
      # Results expandable section (only for completed elections)
      if @election.status == 'completed' && @election.candidates.any?
        expandable(@election, @election.candidacies, title: "Results") do |candidacies|
          results_preview(@election)
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