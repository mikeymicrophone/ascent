class CreateGoverningBodies < ActiveRecord::Migration[8.0]
  def change
    create_table :governing_bodies do |t|
      t.string :name
      t.string :jurisdiction_type
      t.integer :jurisdiction_id
      t.references :governance_type, null: false, foreign_key: true
      t.text :description
      t.string :meeting_schedule
      t.boolean :is_active
      t.date :established_date

      t.timestamps
    end
  end
end
