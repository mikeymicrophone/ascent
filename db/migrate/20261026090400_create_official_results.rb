# The certified outcome of a finished race and the method that decided it, revealed to a voter
# replaying the race only after they save their own mountain.
class CreateOfficialResults < ActiveRecord::Migration[8.1]
  def change
    add_column :races, :decided_by, :string

    create_table :official_results do |t|
      t.references :race, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :candidacy, null: false, foreign_key: { on_delete: :cascade }
      t.integer :votes, null: false
      t.decimal :vote_share, precision: 5, scale: 2
      t.boolean :winner, null: false, default: false
      t.timestamps
    end
    add_index :official_results, [ :race_id, :candidacy_id ], unique: true
    add_check_constraint :official_results, "votes >= 0", name: "official_results_votes_not_negative"
    add_check_constraint :official_results, "vote_share BETWEEN 0 AND 100", name: "official_results_vote_share_in_range"
  end
end
