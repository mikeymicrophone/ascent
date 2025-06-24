class Views::Positions::ShowView < Views::ApplicationView
  def initialize(position:, notice: nil)
    @position = position
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold position-show", id: dom_id(@position, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing position" }
      
      PositionPartial(position: @position)
      
      Ui::ResourceActions(resource: @position)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end