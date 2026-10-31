# frozen_string_literal: true

class Views::VoterRaceBaselines::IndexView < Views::ApplicationView
  prop :voter_race_baselines, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)

  def view_template
    ResourceIndex(collection: @voter_race_baselines, pagy: @pagy, heading: "Baselines",
      lede: "Where each voter draws approval in each race. Only admins see this list.") do |baseline|
      ListRow(record: baseline, title: baseline.voter.full_name, meta: "#{baseline.race.name} · baseline #{baseline.baseline}")
    end
  end
end
