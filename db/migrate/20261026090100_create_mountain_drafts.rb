# A voter's unsaved changes to one race's mountain, kept on the server so a race can show as started
# on any device. Ratings are keyed by candidacy id; a null rating removes a saved one when published.
class CreateMountainDrafts < ActiveRecord::Migration[8.1]
  def change
    create_table :mountain_drafts do |t|
      t.references :voter, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :race, null: false, foreign_key: { on_delete: :cascade }
      t.integer :baseline
      t.jsonb :ratings, null: false, default: {}
      t.timestamps
    end
    add_index :mountain_drafts, [ :voter_id, :race_id ], unique: true
    add_check_constraint :mountain_drafts, "baseline BETWEEN 0 AND 500", name: "mountain_drafts_baseline_in_range"
  end
end
