class Views::Policies::IndexView < Views::ApplicationView
  def initialize(policies:, pagy: nil)
    @policies = policies
    @pagy = pagy
  end

  def view_template(&)
    div(class: "scaffold policies-index", id: "index_policies") do
      div do
        h1 { "Policies" }
        scaffold_new_resource_link "New policy", new_policy_path, record: Policy
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
end
