class CreateYears < ActiveRecord::Migration[8.0]
  def change
    create_table :years do |t|
      t.integer :year
      t.boolean :is_even_year
      t.boolean :is_presidential_year
      t.text :description

      t.timestamps
    end
  end
end
