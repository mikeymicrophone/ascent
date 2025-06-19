class Views::Positions::ShowView < Views::ApplicationView
  def initialize(position:, notice: nil)
    @position = position
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold position-show", id: dom_id(@position, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing position" }
      
      Views::Positions::PositionPartial(position: @position)
      
      div do
        link_to "Edit this position", 
                edit_position_path(@position),
                class: "secondary"
        link_to "Back to positions", 
                positions_path,
                class: "secondary"
        button_to "Destroy this position", 
                  @position,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end