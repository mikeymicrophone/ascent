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
      if @election.candidates.any?
        render_expandable_candidates
      end
      
      # Results expandable section (only for completed elections)
      if @election.status == 'completed' && @election.candidates.any?
        render_expandable_results
      end
    end
  end

  private

  def render_expandable_candidates
    Views::Components::ExpandableSection(
      title: "Candidates",
      count: @election.candidates.count
    ) do
      Views::Components::ItemPreview(@election, :candidacies, 5) do |candidate|
        link_to candidate.name, candidate, class: "link candidate"
        if candidate.respond_to?(:party_affiliation) && candidate.party_affiliation.present?
          span(class: "candidate-party") { " (#{candidate.party_affiliation})" }
        end
      end
    end
  end

  def render_expandable_results
    Views::Components::ExpandableSection(
      title: "Results",
      count: "#{@election.candidates.count} candidates"
    ) do
      render_results_preview
    end
  end

  def render_results_preview
    div(class: "results-preview") do
      # Try to get approval results if available
      if @election.respond_to?(:approval_results)
        results = @election.approval_results
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
            link_to "View full results", @election, class: "link view-all"
          end
        else
          div(class: "no-results") do
            span { "No results available yet" }
          end
        end
      else
        div(class: "results-placeholder") do
          span { "Results calculation not available" }
        end
      end
    end
  end
end