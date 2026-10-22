class Views::VoterRaceBaselines::IndexView < Views::ApplicationView
  prop :voter_race_baselines, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @voter_race_baselines, pagy: @pagy) { VoterRaceBaselinePartial(voter_race_baseline: it) }
  end
end
