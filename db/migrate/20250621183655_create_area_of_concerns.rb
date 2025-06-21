class CreateAreaOfConcerns < ActiveRecord::Migration[8.0]
  def change
    create_table :area_of_concerns do |t|
      t.string :name
      t.text :description
      t.string :policy_domain
      t.string :regulatory_scope

      t.timestamps
    end
  end
end
