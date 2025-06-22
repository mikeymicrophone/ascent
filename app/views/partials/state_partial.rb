class Views::Partials::StatePartial < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    div(id: dom_id(@state), class: "state-partial") do
      h3 { @state.name }
      
      # Hierarchical navigation
      HierarchicalNavigation(current_object: @state)
      
      div do
        span { "Code:" }
        whitespace
        span { @state.code }
      end
      
      # Cities expandable section
      expandable(@state, :cities) do |cities|
        ItemPreview(@state, :cities, 5) do |city|
          link_to city.name, city, class: "link city"
        end
      end
    end
  end
end