class Views::Cities::CityPartial < Views::ApplicationView
  def initialize(city:)
    @city = city
  end

  def view_template(&)
    div(id: dom_id(@city), class: "city-partial") do
      h3 { @city.name }
      div do
        span { "State:" }
        whitespace
        link_to @city.state.name, @city.state, class: "link state"
      end
    end
  end
end
