class Views::AreaOfConcerns::EditView < Views::ApplicationView
  def initialize(area_of_concern:)
    @area_of_concern = area_of_concern
  end

  def view_template(&)
    div(class: "scaffold area_of_concern-edit", id: dom_id(@area_of_concern, :edit)) do
      h1 { "Editing area of concern" }
      
      render Views::AreaOfConcerns::AreaOfConcernForm.new(area_of_concern: @area_of_concern)
      
      div do
        link_to "Show this area of concern", 
                @area_of_concern,
                class: "secondary"
        link_to "Back to area of concerns", 
                area_of_concerns_path,
                class: "secondary"
      end
    end
  end
end