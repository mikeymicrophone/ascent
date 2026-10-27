class CreateEngagements < ActiveRecord::Migration[8.1]
  def change
    create_table :engagements do |t|
      t.references :voter, null: false, foreign_key: true
      t.references :engageable, polymorphic: true, null: false, index: false
      t.string :kind, null: false
      t.timestamps
    end

    add_index :engagements, [ :voter_id, :engageable_type, :engageable_id, :kind ],
      unique: true, name: "index_engagements_once_per_voter_record_and_kind"
    add_index :engagements, [ :engageable_type, :engageable_id, :kind ],
      name: "index_engagements_on_record_and_kind"
    add_check_constraint :engagements, "kind IN ('bookmark', 'favorite', 'follow', 'hide')",
      name: "engagements_kind_is_known"
  end
end
