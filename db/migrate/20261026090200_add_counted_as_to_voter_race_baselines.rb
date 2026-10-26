# A saved mountain counts with the race's residents, or with visitors when the voter does not live
# where the race is decided. The group is fixed when the mountain is saved.
class AddCountedAsToVoterRaceBaselines < ActiveRecord::Migration[8.1]
  def up
    add_column :voter_race_baselines, :counted_as, :string, null: false, default: "visitor"
    add_check_constraint :voter_race_baselines, "counted_as IN ('resident', 'visitor')", name: "voter_race_baselines_counted_as_is_known"
    add_index :voter_race_baselines, [ :race_id, :counted_as ]

    VoterRaceBaseline.reset_column_information
    VoterRaceBaseline.recount!
  end

  def down
    remove_column :voter_race_baselines, :counted_as
  end
end
