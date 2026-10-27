class Views::Residences::ResidenceForm < Views::Components::Forms::Base
  def view_template
    row field(:voter_id).collection_select(::Voter.all, text: :name, prompt: "Select a voter"), label: "Voter"
    row field(:jurisdiction_id).select_choices(jurisdiction_choices, prompt: "Select a jurisdiction"), label: "Jurisdiction"
    row field(:registered_at).datetime
    row field(:started_on).input(type: :date), label: "Moved in"
    row field(:ended_on).input(type: :date), label: "Moved out"
    row field(:status).text
    row field(:notes).textarea(rows: 4)
  end
end
