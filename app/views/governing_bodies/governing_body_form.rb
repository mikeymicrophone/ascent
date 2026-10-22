class Views::GoverningBodies::GoverningBodyForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:jurisdiction_id).select_choices(jurisdiction_choices, prompt: "Select a jurisdiction"), label: "Jurisdiction"
    row field(:governance_type_id).collection_select(::GovernanceType.all, text: :name, prompt: "Select a governance type"), label: "Governance type"
    row field(:branch).select_choices(GoverningBody.branches.keys.map { |branch| [ branch.titleize, branch ] }, include_blank: "None")
    row field(:description).textarea(rows: 4)
    row field(:meeting_schedule).text
    row field(:is_active).checkbox
    row field(:established_date).date
  end
end
