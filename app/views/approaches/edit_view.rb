class Views::Approaches::EditView < Views::ApplicationView
  def initialize(approach:)
    @approach = approach
  end

  def view_template(&)
    div(class: "scaffold approach-edit", id: dom_id(@approach, :edit)) do
      h1 { "Editing approach" }
      
      Views::Approaches::ApproachForm(approach: @approach)
      
      div do
        link_to "Show this approach", 
                @approach,
                class: "secondary"
        link_to "Back to approaches", 
                approaches_path,
                class: "secondary"
      end
    end
  end
end