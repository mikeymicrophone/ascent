class CreateApproaches < ActiveRecord::Migration[8.0]
  def change
    create_table :approaches do |t|
      t.string :title
      t.text :description
      t.references :issue, null: false, foreign_key: true

      t.timestamps
    end
  end
end
