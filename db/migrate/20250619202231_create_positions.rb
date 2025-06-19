class CreatePositions < ActiveRecord::Migration[8.0]
  def change
    create_table :positions do |t|
      t.string :title
      t.text :description
      t.boolean :is_executive
      t.integer :term_length_years

      t.timestamps
    end
  end
end
