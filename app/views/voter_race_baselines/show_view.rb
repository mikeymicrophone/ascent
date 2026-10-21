class Views::VoterRaceBaselines::ShowView < Views::ApplicationView
  def initialize(voter_race_baseline:)
    @voter_race_baseline = voter_race_baseline
  end

  def view_template(&)
    div(class: "scaffold voter_race_baseline-show", id: dom_id(@voter_race_baseline, :show)) do
      h1 { "Showing voter race baseline" }

      VoterRaceBaselinePartial(voter_race_baseline: @voter_race_baseline)

      Ui::ResourceActions(resource: @voter_race_baseline)
    end
  end
end
