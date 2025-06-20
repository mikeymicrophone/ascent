class Views::Positions::IndexView < Views::ApplicationView
  def initialize(positions:, pagy: nil, notice: nil)
    @positions = positions
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold positions-index", id: "index_positions") do
      render_notice if @notice.present?
      
      div do
        h1 { "Positions" }
        link_to "New position", 
                new_position_path,
                class: "primary"
      end

      div(id: "positions") do
        if @positions.any?
          @positions.each do |position|
            div(id: dom_id(position, :list_item)) do
              Views::Positions::PositionPartial(position: position)
              
              div do
                link_to "Show", position,
                        class: "secondary"
                link_to "Edit", edit_position_path(position),
                        class: "secondary"
                button_to "Destroy", position,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No positions found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end