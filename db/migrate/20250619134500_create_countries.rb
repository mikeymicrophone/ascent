class CreateCountries < ActiveRecord::Migration[8.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.string :code
      t.text :description

      t.timestamps
    end
  end
end
