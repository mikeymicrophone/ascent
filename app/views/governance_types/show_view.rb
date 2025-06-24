class Views::GovernanceTypes::ShowView < Views::ApplicationView
  def initialize(governance_type:, notice: nil)
    @governance_type = governance_type
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold governance_type-show", id: dom_id(@governance_type, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing governance type" }
      
      GovernanceTypePartial(governance_type: @governance_type)
      
      Ui::ResourceActions(resource: @governance_type)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end