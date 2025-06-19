class Views::Offices::NewView < Views::ApplicationView
  def initialize(office:)
    @office = office
  end

  def view_template(&)
    div(class: "scaffold office-new", id: dom_id(@office, :new)) do
      h1 { "New office" }
      
      Views::Offices::OfficeForm(office: @office)
      
      div do
        link_to "Back to offices", 
                offices_path,
                class: "secondary"
      end
    end
  end
end