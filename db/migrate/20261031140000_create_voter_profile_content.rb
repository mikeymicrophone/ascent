class CreateVoterProfileContent < ActiveRecord::Migration[8.1]
  def change
    create_table :voter_links do |t|
      t.references :voter, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.string :label, null: false
      t.string :url, null: false
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :voter_links, [ :voter_id, :position, :id ]

    create_table :voter_statements do |t|
      t.references :voter, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.text :body, null: false
      t.boolean :active, null: false, default: true
      t.integer :position, null: false, default: 0
      t.timestamps
    end
    add_index :voter_statements, [ :voter_id, :position, :id ]
  end
end
