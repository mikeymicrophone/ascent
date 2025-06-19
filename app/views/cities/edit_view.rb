class Views::Cities::EditView < Views::ApplicationView
  def initialize(city:)
    @city = city
  end

  def view_template(&)
    div(class: "scaffold city-edit", id: dom_id(@city, :edit)) do
      h1 { "Editing city" }
      
      Views::Cities::CityForm(city: @city)
      
      div do
        link_to "Show this city", 
                @city,
                class: "secondary"
        link_to "Back to cities", 
                cities_path,
                class: "secondary"
      end
    end
  end
end