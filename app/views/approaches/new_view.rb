class Views::Approaches::NewView < Views::ApplicationView
  def initialize(approach:)
    @approach = approach
  end

  def view_template(&)
    div(class: "scaffold approach-new", id: dom_id(@approach, :new)) do
      h1 { "New approach" }
      
      Views::Approaches::ApproachForm(approach: @approach)
      
      div do
        link_to "Back to approaches", 
                approaches_path,
                class: "secondary"
      end
    end
  end
end