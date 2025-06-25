class Views::States::ShowView < Views::ApplicationView
  def initialize(state:, notice: nil)
    @state = state
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold state-show", id: dom_id(@state, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing state" }
      
      StatePartial(state: @state)
      
      Ui::ResourceActions(resource: @state)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end