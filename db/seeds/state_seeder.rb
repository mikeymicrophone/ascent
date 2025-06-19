class StateSeeder
  def self.seed(yaml_paths)
    states_data = load_yaml_files(yaml_paths)
    
    states_data.each do |state_data|
      country = Country.find_by!(code: state_data['country_code'])
      
      state = State.find_or_create_by(
        code: state_data['code'],
        country: country
      ) do |s|
        s.name = state_data['name']
      end
      
      puts "Seeded state: #{state.name} (#{state.code}) in #{country.name}"
    end
  end
  
  private
  
  def self.load_yaml_files(paths)
    data = []
    Array(paths).each do |path|
      Dir.glob(path).each do |file|
        yaml_data = YAML.load_file(file)
        data.concat(yaml_data['states'] || [])
      end
    end
    data
  end
end