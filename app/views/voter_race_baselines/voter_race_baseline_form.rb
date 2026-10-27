class Views::VoterRaceBaselines::VoterRaceBaselineForm < Views::Components::Forms::Base
  def view_template
    row field(:voter_id).collection_select(::Voter.all, text: :name, prompt: "Select a voter"), label: "Voter"
    row field(:race_id).collection_select(::Race.with_naming_details, text: :name, prompt: "Select a race"), label: "Race"
    row field(:baseline).number
  end
end
