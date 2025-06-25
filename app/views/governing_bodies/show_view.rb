class Views::GoverningBodies::ShowView < Views::ApplicationView
  def initialize(governing_body:, notice: nil)
    @governing_body = governing_body
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold governing_body-show", id: dom_id(@governing_body, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing governing body" }
      
      render GoverningBodyPartial.new(governing_body: @governing_body)
      
      Ui::ResourceActions(resource: @governing_body)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end