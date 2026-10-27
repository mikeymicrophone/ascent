# A residence's ballot reaches past its own jurisdiction: the districts it sits in, found either from
# a point inside the boundaries we hold or from the districts recorded for it by hand.
class AddBallotGeographyToResidences < ActiveRecord::Migration[8.1]
  def change
    add_column :residences, :location, :st_point, srid: 4326
    add_index :residences, :location, using: :gist

    create_table :residence_districts do |t|
      t.references :residence, null: false, foreign_key: { on_delete: :cascade }, index: false
      t.references :jurisdiction, null: false, foreign_key: true
      t.timestamps
    end
    add_index :residence_districts, [ :residence_id, :jurisdiction_id ], unique: true
  end
end
