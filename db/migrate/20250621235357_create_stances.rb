class CreateStances < ActiveRecord::Migration[8.0]
  def change
    create_table :stances do |t|
      t.references :candidacy, null: false, foreign_key: true
      t.references :issue, null: false, foreign_key: true
      t.references :approach, null: false, foreign_key: true
      t.text :explanation
      t.string :priority_level
      t.text :evidence_links

      t.timestamps
    end
  end
end
