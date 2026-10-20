class CreateJurisdictions < ActiveRecord::Migration[8.1]
  def change
    rename_table :cities, :municipalities

    create_table :counties do |t|
      t.references :state, null: false, foreign_key: true
      t.string :name, null: false
      t.string :code
      t.timestamps
    end

    add_reference :municipalities, :county, foreign_key: true

    create_table :districts do |t|
      t.string :name, null: false
      t.string :kind, null: false
      t.timestamps
    end

    create_table :jurisdictions do |t|
      t.references :jurisdictionable, polymorphic: true, null: false, index: { unique: true }
      t.references :parent, foreign_key: { to_table: :jurisdictions }
      t.timestamps
    end
    add_check_constraint :jurisdictions, "parent_id <> id", name: "jurisdictions_cannot_parent_themselves"

    create_table :jurisdiction_boundaries do |t|
      t.references :jurisdiction, null: false, foreign_key: true
      t.multi_polygon :geometry, srid: 4326, null: false
      t.date :valid_from, null: false
      t.date :valid_until
      t.timestamps
    end
    add_index :jurisdiction_boundaries, :geometry, using: :gist
    add_check_constraint :jurisdiction_boundaries,
      "ST_IsValid(geometry) AND NOT ST_IsEmpty(geometry)",
      name: "jurisdiction_boundaries_valid_geometry"
    add_check_constraint :jurisdiction_boundaries,
      "valid_until IS NULL OR valid_until > valid_from",
      name: "jurisdiction_boundaries_valid_dates"
    add_exclusion_constraint :jurisdiction_boundaries,
      "jurisdiction_id WITH =, daterange(valid_from, valid_until, '[)') WITH &&",
      using: :gist, name: "jurisdiction_boundaries_cannot_overlap_in_time"

    remove_reference :offices, :jurisdiction, polymorphic: true, null: false
    add_reference :offices, :jurisdiction, null: false, foreign_key: true

    remove_reference :residences, :jurisdiction, polymorphic: true, null: false
    add_reference :residences, :jurisdiction, null: false, foreign_key: true

    remove_reference :governing_bodies, :jurisdiction, polymorphic: true, type: :integer, index: false
    add_reference :governing_bodies, :jurisdiction, null: false, foreign_key: true
  end
end
