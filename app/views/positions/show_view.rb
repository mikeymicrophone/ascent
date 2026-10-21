class Views::Positions::ShowView < Views::ApplicationView
  def initialize(position:)
    @position = position
  end

  def view_template(&)
    div(class: "scaffold position-show", id: dom_id(@position, :show)) do
      h1 { "Showing position" }

      PositionPartial(position: @position)

      Ui::ResourceActions(resource: @position)
    end
  end
end
