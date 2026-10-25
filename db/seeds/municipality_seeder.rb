class MunicipalitySeeder
  def self.seed
    municipalities_data = YAML.load_file(SeedDataPaths.file("cities.yml"))

    municipalities_data.each do |municipality_data|
      state = State.find_by(code: municipality_data["state_code"])
      next unless state

      municipality = Municipality.find_or_create_by!(
        name: municipality_data["name"],
        state: state
      )
      SeedJurisdictions.ensure(municipality, parent: state.jurisdiction)
    end

    puts "Seeded #{Municipality.count} municipalities across #{State.joins(:municipalities).distinct.count} states"
  end
end
