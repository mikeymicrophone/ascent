class Views::Policies::IndexView < Views::ApplicationView
  def initialize(policies:, pagy: nil, notice: nil)
    @policies = policies
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold policies-index", id: "index_policies") do
      render_notice if @notice.present?
      
      div do
        h1 { "Policies" }
        link_to "New policy", 
                new_policy_path,
                class: "primary"
      end

      div(id: "policies") do
        if @policies.any?
          @policies.each do |policy|
            div(id: dom_id(policy, :list_item)) do
              Views::Policies::PolicyPartial(policy: policy)
              
              div do
                link_to "Show", policy,
                        class: "secondary"
                link_to "Edit", edit_policy_path(policy),
                        class: "secondary"
                button_to "Destroy", policy,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No policies found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end