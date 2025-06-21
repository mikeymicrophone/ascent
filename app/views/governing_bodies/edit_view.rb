class Views::GoverningBodies::EditView < Views::ApplicationView
  def initialize(governing_body:)
    @governing_body = governing_body
  end

  def view_template(&)
    div(class: "scaffold governing_body-edit", id: dom_id(@governing_body, :edit)) do
      h1 { "Editing governing body" }
      
      render Views::GoverningBodies::GoverningBodyForm.new(governing_body: @governing_body)
      
      div do
        link_to "Show this governing body", 
                @governing_body,
                class: "secondary"
        link_to "Back to governing bodies", 
                governing_bodies_path,
                class: "secondary"
      end
    end
  end
end