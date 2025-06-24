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
              PolicyPartial(policy: policy)

              Ui::ResourceActions(resource: policy)
            end
          end
        else
          p { "No policies found." }
        end
      end

      Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end
