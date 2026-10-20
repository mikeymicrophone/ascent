class Views::Districts::EditView < Views::ApplicationView
  def initialize(district:)
    @district = district
  end

  def view_template(&)
    div(class: "scaffold district-edit", id: dom_id(@district, :edit)) do
      h1 { "Editing district" }
      
      Views::Districts::DistrictForm(district: @district)
      
      div do
        link_to "Show this district", 
                @district,
                class: "secondary"
        link_to "Back to districts", 
                districts_path,
                class: "secondary"
      end
    end
  end
end