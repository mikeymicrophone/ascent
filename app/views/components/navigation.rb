class Views::Components::Navigation < Views::ApplicationView
  def initialize(current_voter: nil)
    @current_voter = current_voter
  end

  def view_template
    nav(class: "main-navigation") do
      div(class: "nav-container") do
        div(class: "nav-brand") do
          link_to "Ascent", root_path, class: "brand-link"
        end
        
        div(class: "nav-links") do
          # Jurisdictions dropdown
          div(class: "nav-group", data: { controller: "dropdown" }) do
            div(class: "nav-group-header", data: { action: "click->dropdown#toggle" }) do
              span { "Jurisdictions" }
              span(class: "nav-group-arrow") { "▼" }
            end
            div(class: "nav-group-content", data: { dropdown_target: "menu" }) do
              link_to "Countries", countries_path, class: nav_link_class(countries_path)
              link_to "States", states_path, class: nav_link_class(states_path)
              link_to "Cities", cities_path, class: nav_link_class(cities_path)
            end
          end
          
          # Governance dropdown
          div(class: "nav-group", data: { controller: "dropdown" }) do
            div(class: "nav-group-header", data: { action: "click->dropdown#toggle" }) do
              span { "Governance" }
              span(class: "nav-group-arrow") { "▼" }
            end
            div(class: "nav-group-content", data: { dropdown_target: "menu" }) do
              link_to "Positions", positions_path, class: nav_link_class(positions_path)
              link_to "Governance Types", governance_types_path, class: nav_link_class(governance_types_path)
              link_to "Areas of Concern", area_of_concerns_path, class: nav_link_class(area_of_concerns_path)
              link_to "Governing Bodies", governing_bodies_path, class: nav_link_class(governing_bodies_path)
              link_to "Offices", offices_path, class: nav_link_class(offices_path)
            end
          end
          
          # Elections dropdown
          div(class: "nav-group", data: { controller: "dropdown" }) do
            div(class: "nav-group-header", data: { action: "click->dropdown#toggle" }) do
              span { "Elections" }
              span(class: "nav-group-arrow") { "▼" }
            end
            div(class: "nav-group-content", data: { dropdown_target: "menu" }) do
              link_to "Years", years_path, class: nav_link_class(years_path)
              link_to "Elections", elections_path, class: nav_link_class(elections_path)
              link_to "People", people_path, class: nav_link_class(people_path)
              link_to "Candidacies", candidacies_path, class: nav_link_class(candidacies_path)
            end
          end
          
          # Voting dropdown
          div(class: "nav-group", data: { controller: "dropdown" }) do
            div(class: "nav-group-header", data: { action: "click->dropdown#toggle" }) do
              span { "Voting" }
              span(class: "nav-group-arrow") { "▼" }
            end
            div(class: "nav-group-content", data: { dropdown_target: "menu" }) do
              link_to "Voters", voters_path, class: nav_link_class(voters_path)
              link_to "Residences", residences_path, class: nav_link_class(residences_path)
              link_to "Ratings", ratings_path, class: nav_link_class(ratings_path)
              link_to "Baselines", voter_election_baselines_path, class: nav_link_class(voter_election_baselines_path)
              link_to "Mountains", mountains_path, class: nav_link_class(mountains_path)
            end
          end
          
          render Views::Components::DeviseLinks.new(current_voter: @current_voter)
        end
      end
    end
  end

  private

  def nav_link_class(path)
    base_classes = "nav-link"
    current_page?(path) ? "#{base_classes} active" : base_classes
  end
end