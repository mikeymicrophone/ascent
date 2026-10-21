class Views::Positions::IndexView < Views::ApplicationView
  def initialize(positions:, pagy: nil)
    @positions = positions
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold positions-index", id: "index_positions") do
      div do
        h1 { "Positions" }
        scaffold_new_resource_link "New position", new_position_path, record: Position
      end

      div(id: "positions") do
        if @positions.any?
          @positions.each do |position|
            div(id: dom_id(position, :list_item)) do
              PositionPartial(position: position)

              Ui::ResourceActions(resource: position)
            end
          end
        else
          p { "No positions found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end
end
