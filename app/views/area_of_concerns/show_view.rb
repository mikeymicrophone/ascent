class Views::AreaOfConcerns::ShowView < Views::ApplicationView
  def initialize(area_of_concern:, notice: nil)
    @area_of_concern = area_of_concern
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold area_of_concern-show", id: dom_id(@area_of_concern, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing area of concern" }
      
      render AreaOfConcernPartial.new(area_of_concern: @area_of_concern)
      
      Ui::ResourceActions(resource: @area_of_concern)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end