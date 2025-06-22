class CreateIssues < ActiveRecord::Migration[8.0]
  def change
    create_table :issues do |t|
      t.string :title
      t.text :description
      t.references :topic, null: false, foreign_key: true

      t.timestamps
    end
  end
end
