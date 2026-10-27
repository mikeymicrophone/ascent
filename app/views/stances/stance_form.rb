class Views::Stances::StanceForm < Views::Components::Forms::Base
  def view_template
    row field(:candidacy_id).collection_select(::Candidacy.all, text: :name, prompt: "Select a candidacy"), label: "Candidacy"
    row field(:approach_id).collection_select(::Approach.all, text: :name, prompt: "Select an approach"), label: "Approach"
    row field(:explanation).textarea(rows: 4)
    row field(:priority_level).text
    row field(:evidence_links).textarea(rows: 4)
  end
end
