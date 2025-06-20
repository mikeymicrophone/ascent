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
    div(class: "cities-preview") do
      # Show first 5 cities
      cities_to_show = @state.cities.limit(5)
      cities_to_show.each do |city|
        div(class: "city-preview-item") do
          link_to city.name, city, class: "link city"
        end
      end
      
      # Show "View All" link if there are more than 5 cities
      if @state.cities.count > 5
        div(class: "cities-view-all") do
          link_to "View all #{@state.cities.count} cities", 
                  cities_path(state_id: @state.id), 
                  class: "link view-all"
        end
      end
    end
  end
end