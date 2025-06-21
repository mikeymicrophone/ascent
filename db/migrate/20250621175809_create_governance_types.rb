class CreateGovernanceTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :governance_types do |t|
      t.string :name
      t.text :description
      t.integer :authority_level
      t.string :decision_making_process

      t.timestamps
    end
  end
end
