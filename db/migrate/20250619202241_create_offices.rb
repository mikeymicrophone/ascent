class CreateOffices < ActiveRecord::Migration[8.0]
  def change
    create_table :offices do |t|
      t.references :position, null: false, foreign_key: true
      t.references :jurisdiction, null: false, polymorphic: true
      t.boolean :is_active
      t.text :notes

      t.timestamps
    end
  end
end
