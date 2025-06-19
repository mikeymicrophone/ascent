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