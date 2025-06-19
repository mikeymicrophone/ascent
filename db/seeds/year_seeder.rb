class YearSeeder
  def self.seed
    years_data = YAML.load_file(Rails.root.join("db", "seeds", "data", "years.yml"))
    
    years_data.each do |year_data|
      Year.find_or_create_by(year: year_data["year"]) do |year|
        year.is_even_year = year_data["is_even_year"]
        year.is_presidential_year = year_data["is_presidential_year"]
        year.description = year_data["description"]
      end
    end
    
    puts "Seeded #{Year.count} years"
  end
end