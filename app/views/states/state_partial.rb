class Views::States::StatePartial < Views::ApplicationView
  def initialize(state:)
    @state = state
  end

  def view_template(&)
    div(id: dom_id(@state), class: "state-partial") do
      h3 { @state.name }
      div do
        span { "Code:" }
        whitespace
        span { @state.code }
      end
      div do
        span { "Country:" }
        whitespace
        link_to @state.country.name, @state.country, class: "link country"
      end
      
      # Cities expandable section
      if @state.cities.any?
        render_expandable_cities
      end
    end
  end

  private

  def render_expandable_cities
    render Views::Components::ExpandableSection.new(
      title: "Cities",
      count: @state.cities.count
    ) do
      render_cities_preview
    end
  end

  def render_cities_preview
    render Views::Components::ItemPreview.new(
      items: @state.cities,
      limit: 5,
      container_class: "cities-preview",
      item_class: "city-preview-item",
      view_all_class: "cities-view-all",
      view_all_text: "View all #{@state.cities.count} cities",
      view_all_path: cities_path(state_id: @state.id)
    ) do |city|
      link_to city.name, city, class: "link city"
    end
  end
end