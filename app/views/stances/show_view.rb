class Views::Stances::ShowView < Views::ApplicationView
  def initialize(stance:, notice: nil)
    @stance = stance
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold stance-show", id: dom_id(@stance, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing stance" }
      
      StancePartial(stance: @stance)
      
      Ui::ResourceActions(resource: @stance)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end