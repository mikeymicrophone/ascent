class Views::VoterRaceBaselines::NewView < Views::ApplicationView
  def initialize(voter_race_baseline:)
    @voter_race_baseline = voter_race_baseline
  end

  def view_template(&)
    div(class: "scaffold voter_race_baseline-new", id: dom_id(@voter_race_baseline, :new)) do
      h1 { "New voter race baseline" }
      
      Views::VoterRaceBaselines::VoterRaceBaselineForm(voter_race_baseline: @voter_race_baseline)
      
      div do
        link_to "Back to voter race baselines", 
                voter_race_baselines_path,
                class: "secondary"
      end
    end
  end
end