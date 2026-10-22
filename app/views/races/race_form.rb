class Views::Races::RaceForm < Views::Components::Forms::Base
  def view_template
    row field(:election_id).collection_select(::Election.recent, text: :name, prompt: "Select an election"), label: "Election"
    row field(:office_id).collection_select(::Office.includes(:position, jurisdiction: :jurisdictionable), text: :name, prompt: "Select an office"), label: "Office"
    row field(:status).select_choices(%w[upcoming active completed cancelled].map { [ it.capitalize, it ] })
    row field(:description).textarea(rows: 4)
  end
end
