class Views::Cities::NewView < Views::ApplicationView
  def initialize(city:)
    @city = city
  end

  def view_template(&)
    div(class: "scaffold city-new", id: dom_id(@city, :new)) do
      h1 { "New city" }
      
      Views::Cities::CityForm(city: @city)
      
      div do
        link_to "Back to cities", 
                cities_path,
                class: "secondary"
      end
    end
  end
end