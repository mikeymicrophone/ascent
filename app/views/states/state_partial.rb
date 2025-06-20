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
    div(class: "expandable-section", data: { controller: "expandable-section" }) do
      button(
        class: "expandable-header",
        data: { 
          action: "click->expandable-section#toggle",
          expandable_section_target: "toggle"
        }
      ) do
        div(class: "expandable-title") do
          span { "Cities" }
          whitespace
          span(class: "expandable-count") { "(#{@state.cities.count})" }
        end
        div(class: "expandable-icon") do
          span(data: { expandable_section_target: "icon" }) { "▶" }
        end
      end
      
      div(
        class: "expandable-content",
        data: { expandable_section_target: "content" },
        style: "display: none;"
      ) do
        render_cities_preview
      end
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