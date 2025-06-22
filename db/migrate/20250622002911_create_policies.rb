class CreatePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :policies do |t|
      t.references :governing_body, null: false, foreign_key: true
      t.references :area_of_concern, null: false, foreign_key: true
      t.references :approach, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :status
      t.date :enacted_date
      t.date :expiration_date

      t.timestamps
    end
  end
end
