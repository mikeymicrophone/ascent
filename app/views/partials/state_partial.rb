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

      expandable(@state, :counties) do |counties|
        ItemPreview(@state, :counties, 5) do |county|
          link_to county.name, county, class: "link county"
        end
      end

      expandable(@state, :municipalities) do |municipalities|
        ItemPreview(@state, :municipalities, 5) do |municipality|
          link_to municipality.name, municipality, class: "link municipality"
        end
      end
    end
  end
end
