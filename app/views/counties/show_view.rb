class Views::Counties::ShowView < Views::ApplicationView
  def initialize(county:, notice: nil)
    @county = county
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold county-show", id: dom_id(@county, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing county" }
      
      CountyPartial(county: @county)
      
      Ui::ResourceActions(resource: @county)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end