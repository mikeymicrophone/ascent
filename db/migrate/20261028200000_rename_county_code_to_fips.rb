class RenameCountyCodeToFips < ActiveRecord::Migration[8.1]
  def up
    rename_column :counties, :code, :fips
    execute <<~SQL
      UPDATE counties SET fips = NULL WHERE fips = '';

      UPDATE counties SET fips = jurisdictions.census_geoid
      FROM jurisdictions, states, countries
      WHERE jurisdictions.jurisdictionable_type = 'County'
        AND jurisdictions.jurisdictionable_id = counties.id
        AND states.id = counties.state_id AND countries.id = states.country_id
        AND countries.code = 'US' AND counties.fips IS NULL
        AND jurisdictions.census_class = 'G4020'
        AND jurisdictions.census_geoid ~ '^[0-9]{5}$';
    SQL
    conflicts = select_value(<<~SQL).to_i
      SELECT COUNT(*) FROM counties JOIN jurisdictions
        ON jurisdictions.jurisdictionable_type = 'County'
        AND jurisdictions.jurisdictionable_id = counties.id
      WHERE counties.fips IS NOT NULL AND jurisdictions.census_geoid IS NOT NULL
        AND counties.fips <> jurisdictions.census_geoid
    SQL
    raise "#{conflicts} county FIPS values disagree with their jurisdiction Census GEOIDs" if conflicts.positive?
  end

  def down
    rename_column :counties, :fips, :code
  end
end
