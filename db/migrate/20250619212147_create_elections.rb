class CreateElections < ActiveRecord::Migration[8.0]
  def change
    create_table :elections do |t|
      t.references :office, null: false, foreign_key: true
      t.references :year, null: false, foreign_key: true
      t.date :election_date
      t.string :status
      t.text :description
      t.boolean :is_mock
      t.boolean :is_historical

      t.timestamps
    end
  end
end
