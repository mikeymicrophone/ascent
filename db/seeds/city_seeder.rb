class CitySeeder
  def self.seed
    cities_data = YAML.load_file(Rails.root.join("db", "seeds", "data", "cities.yml"))
    
    cities_data.each do |city_data|
      state = State.find_by(code: city_data["state_code"])
      next unless state
      
      city = City.find_or_initialize_by(
        name: city_data["name"],
        state: state
      )
      
      if city.new_record?
        city.save!
      end
    end
    
    puts "Seeded #{City.count} cities across #{State.joins(:cities).distinct.count} states"
  end
end