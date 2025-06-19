class PositionSeeder
  def self.seed
    positions_data = YAML.load_file(Rails.root.join("db", "seeds", "data", "positions.yml"))
    
    positions_data.each do |position_data|
      Position.find_or_create_by(title: position_data["title"]) do |position|
        position.description = position_data["description"]
        position.is_executive = position_data["is_executive"]
        position.term_length_years = position_data["term_length_years"]
      end
    end
    
    puts "Seeded #{Position.count} positions"
  end
end