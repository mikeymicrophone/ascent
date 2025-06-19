class PersonSeeder
  def self.seed
    people_data = YAML.load_file(Rails.root.join("db", "seeds", "data", "people.yml"))
    
    people_data.each do |person_data|
      Person.find_or_create_by(email: person_data["email"]) do |person|
        person.first_name = person_data["first_name"]
        person.last_name = person_data["last_name"]
        person.middle_name = person_data["middle_name"]
        person.birth_date = Date.parse(person_data["birth_date"]) if person_data["birth_date"]
        person.bio = person_data["bio"]
      end
    end
    
    puts "Seeded #{Person.count} people"
  end
end