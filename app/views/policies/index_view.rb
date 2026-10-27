# frozen_string_literal: true

# Every law on Ascent, or one body's, latest first: search by title or narrow by status.
class Views::Policies::IndexView < Views::ApplicationView
  prop :policies, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(GoverningBody)
  prop :filters, Hash

  def view_template
    IndexPage(title: @parent ? "Laws of #{@parent.name}" : "Policies", records: @policies, pagy: @pagy, noun: "policy", frame: "policies-list",
      eyebrow: "Governance", lede: "Laws and policies that put an approach to an issue in place, and the bodies that made them.",
      trail: [ [ "Governing bodies", governing_bodies_path ], *([ [ @parent.name, @parent ] ] if @parent) ], clear_path: list_path,
      actions: (method(:new_policy_link) if scaffold_new_resource_visible?(Policy)), filters: method(:filter_form)) { policy_row(it) }
  end

  private

  def list_path
    @parent ? governing_body_policies_path(@parent) : policies_path
  end

  def new_policy_link
    PillLink(label: "New policy", path: new_policy_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: list_path, label: "Filter policies", placeholder: "Title", values: @filters, clear_path: list_path,
      selects: [ [ :status, "Status", Policy.statuses.keys.map { [ it.capitalize, it ] }, "Any status" ] ])
  end

  def policy_row(policy)
    ListRow(record: policy, title: policy.title,
      meta: [ policy.governing_body&.name, policy.approach && "Approach: #{policy.approach.title}", policy.enacted_date&.year ].compact.join(" · "),
      detail: policy.description.presence) do
      StatusChip(status: policy.status)
    end
  end
end
