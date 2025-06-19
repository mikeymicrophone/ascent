class Views::Offices::EditView < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    div(class: "scaffold office-edit", id: dom_id(@office, :edit)) do
      h1 { "Editing office" }
      
      Views::Offices::OfficeForm(office: @office)
      
      div do
        link_to "Show this office", 
                @office,
                class: "secondary"
        link_to "Back to offices", 
                offices_path,
                class: "secondary"
      end
    end
  end
end