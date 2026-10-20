class Views::VoterRaceBaselines::EditView < Views::ApplicationView
  def initialize(voter_race_baseline:)
    @voter_race_baseline = voter_race_baseline
  end

  def view_template(&)
    div(class: "scaffold voter_race_baseline-edit", id: dom_id(@voter_race_baseline, :edit)) do
      h1 { "Editing voter race baseline" }
      
      Views::VoterRaceBaselines::VoterRaceBaselineForm(voter_race_baseline: @voter_race_baseline)
      
      div do
        link_to "Show this voter race baseline", 
                @voter_race_baseline,
                class: "secondary"
        link_to "Back to voter race baselines", 
                voter_race_baselines_path,
                class: "secondary"
      end
    end
  end
end