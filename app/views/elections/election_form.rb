class Views::Elections::ElectionForm < Views::Components::Forms::Base
  def view_template
    row field(:name).text
    row field(:jurisdiction_id).select_choices(jurisdiction_choices, prompt: "Select a jurisdiction"), label: "Jurisdiction"
    row field(:kind).select_choices(%w[primary general special runoff].map { [ it.capitalize, it ] }, include_blank: "None")
    row field(:year_id).collection_select(::Year.all, text: :name, prompt: "Select a year"), label: "Year"
    row field(:election_date).date
    row field(:early_voting_starts_on).date
    row field(:early_voting_ends_on).date
    row field(:status).text
    row field(:description).textarea(rows: 4)
    row field(:is_mock).checkbox
    row field(:is_historical).checkbox
  end
end
