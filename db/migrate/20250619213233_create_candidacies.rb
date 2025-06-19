class CreateCandidacies < ActiveRecord::Migration[8.0]
  def change
    create_table :candidacies do |t|
      t.references :person, null: false, foreign_key: true
      t.references :election, null: false, foreign_key: true
      t.string :status
      t.date :announcement_date
      t.string :party_affiliation
      t.text :platform_summary

      t.timestamps
    end
  end
end
