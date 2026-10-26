# A residence has one shape: a town (or county, outside any town), the House, state senate and state
# assembly districts it sits in, and the dates it was lived in. The open-ended one is current; voters
# can add past ones the same way. Districts recorded loosely move into their slots by kind, and the
# unused map location is dropped: a residence keeps places, never a point.
class GiveResidencesTheirDistricts < ActiveRecord::Migration[8.1]
  SLOTS = {
    congressional_district_id: "kind LIKE '%congressional%'",
    state_senate_district_id: "kind = 'state senate district'",
    state_house_district_id: "kind IN ('state house district', 'assembly district', 'house of delegates district')"
  }.freeze

  def up
    SLOTS.each_key { add_reference :residences, it.to_s.delete_suffix("_id"), foreign_key: { to_table: :jurisdictions } }
    add_column :residences, :started_on, :date
    add_column :residences, :ended_on, :date

    execute <<~SQL
      UPDATE residences SET started_on = registered_at::date,
        ended_on = CASE WHEN status = 'active' THEN NULL ELSE GREATEST(updated_at::date, registered_at::date) END
    SQL
    SLOTS.each do |column, kinds|
      execute <<~SQL
        UPDATE residences SET #{column} = residence_districts.jurisdiction_id
        FROM residence_districts
        JOIN jurisdictions ON jurisdictions.id = residence_districts.jurisdiction_id AND jurisdictions.jurisdictionable_type = 'District'
        JOIN districts ON districts.id = jurisdictions.jurisdictionable_id AND districts.#{kinds}
        WHERE residence_districts.residence_id = residences.id
      SQL
    end

    change_column_null :residences, :started_on, false
    add_check_constraint :residences, "ended_on IS NULL OR ended_on >= started_on", name: "residences_end_after_start"
    drop_table :residence_districts
    remove_column :residences, :location
  end

  def down
    add_column :residences, :location, :st_point, srid: 4326
    create_table :residence_districts do |t|
      t.references :residence, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :jurisdiction, null: false, foreign_key: true
      t.timestamps
    end
    add_index :residence_districts, [ :residence_id, :jurisdiction_id ], unique: true
    SLOTS.each_key do |column|
      execute <<~SQL
        INSERT INTO residence_districts (residence_id, jurisdiction_id, created_at, updated_at)
        SELECT id, #{column}, NOW(), NOW() FROM residences WHERE #{column} IS NOT NULL
      SQL
    end
    remove_check_constraint :residences, name: "residences_end_after_start"
    remove_column :residences, :ended_on
    remove_column :residences, :started_on
    SLOTS.each_key { remove_reference :residences, it.to_s.delete_suffix("_id"), foreign_key: { to_table: :jurisdictions } }
  end
end
