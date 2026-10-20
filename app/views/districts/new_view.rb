class Views::Districts::NewView < Views::ApplicationView
  def initialize(district:)
    @district = district
  end

  def view_template(&)
    div(class: "scaffold district-new", id: dom_id(@district, :new)) do
      h1 { "New district" }
      
      Views::Districts::DistrictForm(district: @district)
      
      div do
        link_to "Back to districts", 
                districts_path,
                class: "secondary"
      end
    end
  end
end