class Views::VoterRaceBaselines::EditView < Views::ApplicationView
  prop :voter_race_baseline, VoterRaceBaseline

  def view_template
    ResourceFormPage(record: @voter_race_baseline) { render Views::VoterRaceBaselines::VoterRaceBaselineForm.new(@voter_race_baseline) }
  end
end
