class Views::OfficialCodes::OfficialCodeForm < Views::Components::Forms::Base
  def view_template
    row field(:policy_id).collection_select(::Policy.all, text: :name, prompt: "Select a policy"), label: "Policy"
    row field(:code_number).text
    row field(:title).text
    row field(:full_text).textarea(rows: 4)
    row field(:summary).textarea(rows: 4)
    row field(:enforcement_mechanism).textarea(rows: 4)
    row field(:penalty_structure).textarea(rows: 4)
    row field(:effective_date).date
    row field(:status).text
  end
end
