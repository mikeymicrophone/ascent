class CountrySeeder
  def self.seed(yaml_paths)
    countries_data = load_yaml_files(yaml_paths)
    
    countries_data.each do |country_data|
      country = Country.find_or_create_by(code: country_data['code']) do |c|
        c.name = country_data['name']
        c.description = country_data['description']
      end
      
      puts "Seeded country: #{country.name} (#{country.code})"
    end
  end
  
  private
  
  def self.load_yaml_files(paths)
    data = []
    Array(paths).each do |path|
      Dir.glob(path).each do |file|
        yaml_data = YAML.load_file(file)
        data.concat(yaml_data['countries'] || [])
      end
    end
    data
  end
end