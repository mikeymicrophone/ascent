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
      
      div do
        link_to "Edit this policy", 
                edit_policy_path(@policy),
                class: "secondary"
        link_to "Back to policies", 
                policies_path,
                class: "secondary"
        button_to "Destroy this policy", 
                  @policy,
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