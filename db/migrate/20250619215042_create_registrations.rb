class CreateRegistrations < ActiveRecord::Migration[8.0]
  def change
    create_table :registrations do |t|
      t.references :voter, null: false, foreign_key: true
      t.references :jurisdiction, null: false, polymorphic: true
      t.datetime :registered_at
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
