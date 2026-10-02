class PositionSeeder
  def self.seed
    positions_data = YAML.load_file(SeedDataPaths.file("positions.yml"))
    
    positions_data.each do |position_data|
      position = Position.find_or_initialize_by(title: position_data["title"])
      position.description = position_data["description"]
      position.branch = position_data["branch"]
      position.term_length_years = position_data["term_length_years"]
      position.save!
    end
    
    puts "Seeded #{Position.count} positions"
  end
end
