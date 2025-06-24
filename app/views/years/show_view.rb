class Views::Years::ShowView < Views::ApplicationView
  def initialize(year:, notice: nil)
    @year = year
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold year-show", id: dom_id(@year, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing year" }
      
      YearPartial(year: @year)
      
      Ui::ResourceActions(resource: @year)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end