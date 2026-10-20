class Views::Counties::NewView < Views::ApplicationView
  def initialize(county:)
    @county = county
  end

  def view_template(&)
    div(class: "scaffold county-new", id: dom_id(@county, :new)) do
      h1 { "New county" }
      
      Views::Counties::CountyForm(county: @county)
      
      div do
        link_to "Back to counties", 
                counties_path,
                class: "secondary"
      end
    end
  end
end