class Views::Partials::MunicipalityPartial < Views::ApplicationView
  def initialize(municipality:)
    @municipality = municipality
  end

  def view_template(&)
    div(id: dom_id(@municipality), class: "municipality-partial") do
      h3 { @municipality.name }
      
      # Hierarchical navigation
      HierarchicalNavigation(current_object: @municipality)
      
      # Offices expandable section
      expandable(@municipality, :offices) do |offices|
        ItemPreview(@municipality, :offices, 3) do |office|
          link_to office.name, office, class: "link office"
          span(class: "office-position") { " (#{office.position.title})" }
        end
      end
      
      # Active Elections expandable section
      expandable(@municipality, :active_elections, title: "Active Elections") do |elections|
        ItemPreview(@municipality, :active_elections, 3) do |election|
          link_to election.name, election, class: "link election"
          div(class: "election-status") do
            span(class: "status-indicator status-#{election.status}") { election.status.capitalize }
            if election.election_date
              span(class: "election-date") { " - #{election.election_date.to_fs(:display)}" }
            end
          end
        end
      end
    end
  end
end
