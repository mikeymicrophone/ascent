class Views::Districts::ShowView < Views::ApplicationView
  def initialize(district:, notice: nil)
    @district = district
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold district-show", id: dom_id(@district, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing district" }
      
      DistrictPartial(district: @district)
      
      Ui::ResourceActions(resource: @district)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end