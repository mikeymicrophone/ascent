class Views::Policies::ShowView < Views::ApplicationView
  def initialize(policy:, notice: nil)
    @policy = policy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold policy-show", id: dom_id(@policy, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing policy" }
      
      PolicyPartial(policy: @policy)
      
      Ui::ResourceActions(resource: @policy)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end