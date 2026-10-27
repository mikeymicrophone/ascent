# How a voter treats one race, starting with whether they also rate the candidates its primaries eliminated.
class CreateVoterRacePreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :voter_race_preferences do |t|
      t.references :voter, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :race, null: false, foreign_key: { on_delete: :cascade }
      t.boolean :include_primary_candidates, null: false, default: false
      t.timestamps
    end
    add_index :voter_race_preferences, [ :voter_id, :race_id ], unique: true
  end
end
