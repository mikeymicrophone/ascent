class Views::Positions::EditView < Views::ApplicationView
  def initialize(position:)
    @position = position
  end

  def view_template(&)
    div(class: "scaffold position-edit", id: dom_id(@position, :edit)) do
      h1 { "Editing position" }
      
      Views::Positions::PositionForm(position: @position)
      
      div do
        link_to "Show this position", 
                @position,
                class: "secondary"
        link_to "Back to positions", 
                positions_path,
                class: "secondary"
      end
    end
  end
end