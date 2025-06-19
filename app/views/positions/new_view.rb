class Views::Positions::NewView < Views::ApplicationView
  def initialize(position:)
    @position = position
  end

  def view_template(&)
    div(class: "scaffold position-new", id: dom_id(@position, :new)) do
      h1 { "New position" }
      
      Views::Positions::PositionForm(position: @position)
      
      div do
        link_to "Back to positions", 
                positions_path,
                class: "secondary"
      end
    end
  end
end