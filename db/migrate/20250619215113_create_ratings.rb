class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |t|
      t.references :voter, null: false, foreign_key: true
      t.references :candidacy, null: false, foreign_key: true
      t.integer :rating
      t.integer :baseline

      t.timestamps
    end
  end
end
