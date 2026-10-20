class Views::Counties::EditView < Views::ApplicationView
  def initialize(county:)
    @county = county
  end

  def view_template(&)
    div(class: "scaffold county-edit", id: dom_id(@county, :edit)) do
      h1 { "Editing county" }
      
      Views::Counties::CountyForm(county: @county)
      
      div do
        link_to "Show this county", 
                @county,
                class: "secondary"
        link_to "Back to counties", 
                counties_path,
                class: "secondary"
      end
    end
  end
end