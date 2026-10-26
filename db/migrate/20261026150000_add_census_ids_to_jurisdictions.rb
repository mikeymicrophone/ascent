# A jurisdiction's identity in the Census Bureau's TIGER/Line files: its feature class (MTFCC, such as
# G4020 for a county) and its GEOID within that class. GEOIDs repeat across classes, so the pair is
# what identifies a feature, and lets a later boundary import match exactly instead of by name.
class AddCensusIdsToJurisdictions < ActiveRecord::Migration[8.1]
  def change
    add_column :jurisdictions, :census_class, :string
    add_column :jurisdictions, :census_geoid, :string
    add_index :jurisdictions, [ :census_class, :census_geoid ], unique: true, where: "census_geoid IS NOT NULL"
    add_check_constraint :jurisdictions, "(census_class IS NULL) = (census_geoid IS NULL)", name: "jurisdictions_census_ids_together"
  end
end
