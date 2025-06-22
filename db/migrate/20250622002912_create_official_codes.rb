class CreateOfficialCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :official_codes do |t|
      t.references :policy, null: false, foreign_key: true
      t.string :code_number
      t.string :title
      t.text :full_text
      t.text :summary
      t.text :enforcement_mechanism
      t.text :penalty_structure
      t.date :effective_date
      t.string :status

      t.timestamps
    end
  end
end
