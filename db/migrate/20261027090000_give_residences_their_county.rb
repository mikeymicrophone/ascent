# A city can span several counties, so its jurisdiction sits under the state and its county's offices
# never reach its residents' ballots. A residence records its county the way it records its districts.
class GiveResidencesTheirCounty < ActiveRecord::Migration[8.1]
  def change
    add_reference :residences, :county, foreign_key: { to_table: :jurisdictions }
  end
end
