class Views::GoverningBodies::NewView < Views::ApplicationView
  def initialize(governing_body:)
    @governing_body = governing_body
  end

  def view_template(&)
    div(class: "scaffold governing_body-new", id: dom_id(@governing_body, :new)) do
      h1 { "New governing body" }
      
      render Views::GoverningBodies::GoverningBodyForm.new(governing_body: @governing_body)
      
      div do
        link_to "Back to governing bodies", 
                governing_bodies_path,
                class: "secondary"
      end
    end
  end
end