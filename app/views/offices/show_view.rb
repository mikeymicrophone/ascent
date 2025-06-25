class Views::Offices::ShowView < Views::ApplicationView
  def initialize(office:, notice: nil)
    @office = office
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold office-show", id: dom_id(@office, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing office" }
      
      OfficePartial(office: @office)
      
      Ui::ResourceActions(resource: @office)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end