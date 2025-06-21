class Views::GovernanceTypes::ShowView < Views::ApplicationView
  def initialize(governance_type:, notice: nil)
    @governance_type = governance_type
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold governance_type-show", id: dom_id(@governance_type, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing governance type" }
      
      Views::GovernanceTypes::GovernanceTypePartial(governance_type: @governance_type)
      
      div do
        link_to "Edit this governance type", 
                edit_governance_type_path(@governance_type),
                class: "secondary"
        link_to "Back to governance types", 
                governance_types_path,
                class: "secondary"
        button_to "Destroy this governance type", 
                  @governance_type,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end