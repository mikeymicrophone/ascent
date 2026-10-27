class AddEntityCodes < ActiveRecord::Migration[8.1]
  CODED_TABLES = %i[
    countries states counties municipalities districts positions
    offices elections races people candidacies
  ].freeze

  def change
    CODED_TABLES.each do |table|
      add_column table, :entity_code, :string
      add_index table, :entity_code, unique: true
    end

    create_table :entity_codes do |t|
      t.string :namespace, null: false
      t.string :catalog, null: false
      t.string :code, null: false
      t.string :canonical_code, null: false
      t.references :record, polymorphic: true
      t.timestamps
    end
    add_index :entity_codes, [ :namespace, :catalog, :code ], unique: true
    add_index :entity_codes, [ :namespace, :catalog, :canonical_code ]

    add_column :people, :username, :string
    add_column :people, :username_status, :string
    add_index :people, :username, unique: true

    add_column :offices, :seat_code, :string
  end
end
