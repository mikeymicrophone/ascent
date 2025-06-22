class Views::Cities::IndexView < Views::ApplicationView
  def initialize(cities:, pagy: nil, notice: nil, filtered_state: nil)
    @cities = cities
    @pagy = pagy
    @notice = notice
    @filtered_state = filtered_state
  end

  def view_template(&)
    div(class: "scaffold cities-index", id: "index_cities") do
      render_notice if @notice.present?
      
      div do
        h1 do
          if @filtered_state
            "Cities in #{@filtered_state.name}"
          else
            "Cities"
          end
        end
        
        if @filtered_state
          div(class: "filter-info") do
            span { "Showing cities in " }
            link_to @filtered_state.name, @filtered_state, class: "link state"
            span { " - " }
            link_to "View all cities", cities_path, class: "link view-all"
          end
        end
        
        link_to "New city", 
                new_city_path,
                class: "primary"
      end

      div(id: "cities") do
        if @cities.any?
          @cities.each do |city|
            div(id: dom_id(city, :list_item)) do
              CityPartial(city: city)
              
              div do
                link_to "Show", city,
                        class: "secondary"
                link_to "Edit", edit_city_path(city),
                        class: "secondary"
                button_to "Destroy", city,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No cities found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end