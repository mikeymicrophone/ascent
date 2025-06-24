class Views::Approaches::ShowView < Views::ApplicationView
  def initialize(approach:, notice: nil)
    @approach = approach
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold approach-show", id: dom_id(@approach, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing approach" }
      
      ApproachPartial(approach: @approach)
      
      Ui::ResourceActions(resource: @approach)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end