class Views::Components::Navigation < Views::ApplicationView
  def view_template
    nav(class: "main-navigation") do
      div(class: "nav-container") do
        div(class: "nav-brand") do
          link_to "Ascent", root_path, class: "brand-link"
        end
        
        div(class: "nav-links") do
          link_to "Countries", countries_path, class: nav_link_class(countries_path)
          link_to "States", states_path, class: nav_link_class(states_path)
          link_to "Cities", cities_path, class: nav_link_class(cities_path)
          link_to "Positions", positions_path, class: nav_link_class(positions_path)
          link_to "Offices", offices_path, class: nav_link_class(offices_path)
          link_to "Years", years_path, class: nav_link_class(years_path)
          link_to "Elections", elections_path, class: nav_link_class(elections_path)
          link_to "People", people_path, class: nav_link_class(people_path)
          link_to "Candidacies", candidacies_path, class: nav_link_class(candidacies_path)
          link_to "Voters", voters_path, class: nav_link_class(voters_path)
          link_to "Registrations", registrations_path, class: nav_link_class(registrations_path)
          link_to "Ratings", ratings_path, class: nav_link_class(ratings_path)
          link_to "Baselines", voter_election_baselines_path, class: nav_link_class(voter_election_baselines_path)
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