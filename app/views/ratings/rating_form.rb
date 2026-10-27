class Views::Ratings::RatingForm < Views::Components::Forms::Base
  def view_template
    row field(:voter_id).collection_select(::Voter.all, text: :name, prompt: "Select a voter"), label: "Voter"
    row field(:candidacy_id).collection_select(::Candidacy.all, text: :name, prompt: "Select a candidacy"), label: "Candidacy"
    row field(:rating).number
  end
end
