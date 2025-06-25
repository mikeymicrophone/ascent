class Views::OfficialCodes::ShowView < Views::ApplicationView
  def initialize(official_code:, notice: nil)
    @official_code = official_code
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold official_code-show", id: dom_id(@official_code, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing official code" }
      
      OfficialCodePartial(official_code: @official_code)
      
      Ui::ResourceActions(resource: @official_code)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end