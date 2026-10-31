class CreatePublicMountains < ActiveRecord::Migration[8.1]
  def change
    create_table :public_mountains do |t|
      t.references :voter, null: false, foreign_key: true
      t.references :race, null: false, foreign_key: true
      t.jsonb :snapshot, null: false
      t.binary :preview_png, null: false
      t.timestamps
    end
    add_index :public_mountains, [ :voter_id, :race_id ], unique: true
  end
end
