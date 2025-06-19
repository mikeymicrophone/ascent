class VoterSeeder
  def self.seed
    voters_data = YAML.load_file(Rails.root.join("db", "seeds", "data", "voters.yml"))
    
    voters_data.each do |voter_data|
      voter = Voter.find_or_initialize_by(email: voter_data["email"])
      
      if voter.new_record?
        voter.assign_attributes(
          first_name: voter_data["first_name"],
          last_name: voter_data["last_name"],
          birth_date: Date.parse(voter_data["birth_date"]),
          is_verified: voter_data["is_verified"],
          password: "password123", # Default password for seeding
          password_confirmation: "password123"
        )
        # No email confirmation needed for basic seeding
        voter.save!
      end
    end
    
    puts "Seeded #{Voter.count} voters"
  end
end