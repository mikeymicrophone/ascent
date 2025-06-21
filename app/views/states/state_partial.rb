class Views::States::StatePartial < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    div(id: dom_id(@state), class: "state-partial") do
      h3 { @state.name }
      
      # Hierarchical navigation
      Views::Components::HierarchicalNavigation(current_object: @state)
      
      div do
        span { "Code:" }
        whitespace
        span { @state.code }
      end
      
      # Cities expandable section
      if @state.cities.any?
        render_expandable_cities
      end
    end
  end

  private

  def render_expandable_cities
    Views::Components::ExpandableSection(
      title: "Cities",
      count: @state.cities.count
    ) do
      Views::Components::ItemPreview(@state, :cities, 5) do |city|
        link_to city.name, city, class: "link city"
      end
    end
  end
end