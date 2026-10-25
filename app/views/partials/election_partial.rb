class Views::Partials::ElectionPartial < Views::ApplicationView
  def initialize(election:)
    @election = election
  end

  def view_template(&)
    div(id: dom_id(@election), class: "election-partial") do
      div(class: "partial-header") do
        h3(class: "partial-title") { @election.name }
        div(class: "header-indicators") do
          span(class: "status-indicator status-#{@election.status}") { @election.status.capitalize }
          if @election.kind.present?
            span(class: "status-indicator status-kind") { @election.kind.capitalize }
          end
          if @election.is_mock
            span(class: "status-indicator status-mock") { "Mock Election" }
          end
          if @election.is_historical
            span(class: "status-indicator status-historical") { "Historical" }
          end
        end
      end

      div(class: "partial-content") do
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Jurisdiction" }
            jurisdiction_link @election.jurisdiction
          end
          div(class: "info-item") do
            span(class: "info-label") { "Year" }
            link_to @election.year.name, @election.year, class: "link year info-value"
          end
          div(class: "info-item") do
            span(class: "info-label") { "Election Date" }
            span(class: "info-value") { @election.election_date.to_fs(:display) }
          end
          early_voting_period if @election.early_voting_starts_on || @election.early_voting_ends_on
        end

        if @election.description.present?
          div(class: "content-section") do
            div(class: "content-description") { simple_format(@election.description) }
          end
        end
      end

      div(class: "expandable-sections") do
        expandable(@election, :races, title: "Races") do |races|
          div(class: "expandable-grid") do
            ItemPreview(@election, :races, 5) do |race|
              race_item race
            end
          end
        end
      end
    end
  end

  def race_item(race)
    div(class: "race-preview-item") do
      link_to race.office.name, race, class: "link race"
      span(class: "status-indicator status-#{race.status}") { race.status.capitalize }
      span(class: "race-candidate-count") { " #{pluralize(race.candidacies.size, 'candidate')}" }
    end
  end

  def early_voting_period
    div(class: "info-item") do
      span(class: "info-label") { "Early Voting" }
      span(class: "info-value") do
        [ @election.early_voting_starts_on, @election.early_voting_ends_on ]
          .map { it&.to_fs(:display) || "TBD" }
          .join(" – ")
      end
    end
  end
end
