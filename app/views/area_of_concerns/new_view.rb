class Views::AreaOfConcerns::NewView < Views::ApplicationView
  def initialize(area_of_concern:)
    @area_of_concern = area_of_concern
  end

  def view_template(&)
    div(class: "scaffold area_of_concern-new", id: dom_id(@area_of_concern, :new)) do
      h1 { "New area of concern" }
      
      render Views::AreaOfConcerns::AreaOfConcernForm.new(area_of_concern: @area_of_concern)
      
      div do
        link_to "Back to area of concerns", 
                area_of_concerns_path,
                class: "secondary"
      end
    end
  end
end