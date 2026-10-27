class Views::VoterRaceBaselines::ShowView < Views::ApplicationView
  prop :voter_race_baseline, VoterRaceBaseline

  def view_template
    ResourceShow(record: @voter_race_baseline) { VoterRaceBaselinePartial(voter_race_baseline: @voter_race_baseline) }
  end
end
