class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :first_name
      t.string :last_name
      t.string :middle_name
      t.string :email
      t.date :birth_date
      t.text :bio

      t.timestamps
    end
  end
end
