class ResidenceSeeder
  def self.seed
    # Create realistic voter residence patterns showing mobility
    create_college_student_residences
    create_professional_relocation_residences
    create_retirement_move_residences
    create_stable_long_term_residences
    
    puts "Seeded #{Residence.count} residences"
  end
  
  private
  
  def self.create_college_student_residences
    # Student who moved from home state to college state
    student = Voter.find_by(email: "emily.johnson@email.com")
    return unless student
    
    california = State.joins(:country).find_by(name: "California", countries: { name: "United States" })
    new_york = State.joins(:country).find_by(name: "New York", countries: { name: "United States" })
    
    return unless california && new_york
    
    # Original residence in California (home state)
    Residence.find_or_create_by(
      voter: student,
      jurisdiction: california,
      status: "inactive"
    ) do |res|
      res.registered_at = 5.years.ago
      res.notes = "Original voter residence in home state"
    end
    
    # Current residence in New York (college state)
    Residence.find_or_create_by(
      voter: student,
      jurisdiction: new_york,
      status: "active"
    ) do |res|
      res.registered_at = 2.years.ago
      res.notes = "Moved for college, established residence"
    end
  end
  
  def self.create_professional_relocation_residences
    # Professional who moved for job opportunities
    professional = Voter.find_by(email: "michael.chen@email.com")
    return unless professional
    
    florida = State.joins(:country).find_by(name: "Florida", countries: { name: "United States" })
    california = State.joins(:country).find_by(name: "California", countries: { name: "United States" })
    
    return unless florida && california
    
    # Original residence in Florida
    Residence.find_or_create_by(
      voter: professional,
      jurisdiction: florida,
      status: "moved"
    ) do |res|
      res.registered_at = 8.years.ago
      res.notes = "First job out of college"
    end
    
    # Current residence in California
    Residence.find_or_create_by(
      voter: professional,
      jurisdiction: california,
      status: "active"
    ) do |res|
      res.registered_at = 3.years.ago
      res.notes = "Relocated for senior position at tech company"
    end
  end
  
  def self.create_retirement_move_residences
    # Retiree who moved to different state
    retiree = Voter.find_by(email: "robert.davis@email.com")
    return unless retiree
    
    georgia = State.joins(:country).find_by(name: "Georgia", countries: { name: "United States" })
    florida = State.joins(:country).find_by(name: "Florida", countries: { name: "United States" })
    
    return unless georgia && florida
    
    # Long-term residence in Georgia
    Residence.find_or_create_by(
      voter: retiree,
      jurisdiction: georgia,
      status: "moved"
    ) do |res|
      res.registered_at = 25.years.ago
      res.notes = "Career and family life in Georgia"
    end
    
    # Current residence in Florida
    Residence.find_or_create_by(
      voter: retiree,
      jurisdiction: florida,
      status: "active"
    ) do |res|
      res.registered_at = 1.year.ago
      res.notes = "Retirement relocation for weather and taxes"
    end
  end
  
  def self.create_stable_long_term_residences
    # Voters who have stayed in the same jurisdiction
    stable_voters = [
      "david.thompson.voter@email.com",
      "jessica.williams@email.com",
      "maria.garcia.voter@email.com",
      "kevin.lee@email.com"
    ]
    
    states = State.joins(:country).where(countries: { name: "United States" }).limit(4)
    
    stable_voters.each_with_index do |email, index|
      voter = Voter.find_by(email: email)
      state = states[index]
      
      next unless voter && state
      
      Residence.find_or_create_by(
        voter: voter,
        jurisdiction: state,
        status: "active"
      ) do |res|
        res.registered_at = rand(15..30).years.ago
        res.notes = "Long-term resident, stable residence"
      end
    end
    
    # Also create some city-level residences
    cities = City.limit(5)
    remaining_voters = Voter.where.not(
      email: stable_voters + [
        "emily.johnson@email.com",
        "michael.chen@email.com", 
        "robert.davis@email.com"
      ]
    ).limit(5)
    
    remaining_voters.each_with_index do |voter, index|
      city = cities[index]
      next unless city
      
      Residence.find_or_create_by(
        voter: voter,
        jurisdiction: city,
        status: "active"
      ) do |res|
        res.registered_at = rand(2..10).years.ago
        res.notes = "City-level residence"
      end
    end
  end
end