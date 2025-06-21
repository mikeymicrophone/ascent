class AreaOfConcernSeeder
  def self.seed
    areas_of_concern = [
      {
        name: "Public Safety",
        description: "Policies and programs related to law enforcement, emergency services, crime prevention, and community safety initiatives.",
        policy_domain: "Safety & Security",
        regulatory_scope: "Municipal, County, State"
      },
      {
        name: "Education Policy",
        description: "Educational standards, funding, curriculum development, school administration, and educational equity programs.",
        policy_domain: "Human Services",
        regulatory_scope: "Local School District, State, Federal"
      },
      {
        name: "Transportation Infrastructure",
        description: "Road maintenance, public transit systems, traffic management, pedestrian safety, and transportation planning.",
        policy_domain: "Infrastructure",
        regulatory_scope: "Municipal, County, Regional, State"
      },
      {
        name: "Environmental Protection",
        description: "Environmental regulations, conservation programs, pollution control, climate action, and natural resource management.",
        policy_domain: "Environment",
        regulatory_scope: "All Levels"
      },
      {
        name: "Economic Development",
        description: "Business incentives, zoning regulations, economic growth strategies, workforce development, and small business support.",
        policy_domain: "Economic",
        regulatory_scope: "Municipal, County, State, Federal"
      },
      {
        name: "Healthcare Services",
        description: "Public health programs, healthcare access, health insurance policies, disease prevention, and health emergency preparedness.",
        policy_domain: "Human Services", 
        regulatory_scope: "County, State, Federal"
      },
      {
        name: "Housing & Urban Development",
        description: "Affordable housing programs, zoning laws, building codes, homelessness services, and community development.",
        policy_domain: "Infrastructure",
        regulatory_scope: "Municipal, County, State, Federal"
      },
      {
        name: "Social Services",
        description: "Welfare programs, disability services, senior services, child protective services, and community support programs.",
        policy_domain: "Human Services",
        regulatory_scope: "County, State, Federal"
      },
      {
        name: "Parks & Recreation",
        description: "Park maintenance, recreational programs, sports facilities, cultural events, and community centers.",
        policy_domain: "Quality of Life",
        regulatory_scope: "Municipal, County, Special District"
      },
      {
        name: "Budget & Finance",
        description: "Government budgeting, taxation policies, debt management, financial transparency, and fiscal responsibility.",
        policy_domain: "Governance",
        regulatory_scope: "All Levels"
      },
      {
        name: "Technology & Innovation",
        description: "Digital infrastructure, cybersecurity, government technology services, broadband access, and digital equity.",
        policy_domain: "Infrastructure",
        regulatory_scope: "Municipal, County, State, Federal"
      },
      {
        name: "Agriculture & Food Security",
        description: "Agricultural policies, food safety regulations, farming support programs, and local food systems.",
        policy_domain: "Economic",
        regulatory_scope: "County, State, Federal"
      },
      {
        name: "Energy Policy",
        description: "Renewable energy programs, utility regulations, energy efficiency standards, and energy independence initiatives.",
        policy_domain: "Environment",
        regulatory_scope: "Municipal, County, State, Federal"
      },
      {
        name: "Immigration & Integration",
        description: "Immigration services, refugee resettlement, citizenship programs, and community integration support.",
        policy_domain: "Human Services",
        regulatory_scope: "Municipal, County, State, Federal"
      },
      {
        name: "Arts & Culture",
        description: "Cultural programs, arts funding, historic preservation, museums, libraries, and community cultural events.",
        policy_domain: "Quality of Life",
        regulatory_scope: "Municipal, County, State"
      }
    ]
    
    areas_of_concern.each do |aoc_attrs|
      area_of_concern = AreaOfConcern.find_or_create_by(name: aoc_attrs[:name]) do |aoc|
        aoc.description = aoc_attrs[:description]
        aoc.policy_domain = aoc_attrs[:policy_domain]
        aoc.regulatory_scope = aoc_attrs[:regulatory_scope]
      end
      
      if area_of_concern.persisted?
        print "."
      else
        puts "\n❌ Failed to create area of concern: #{aoc_attrs[:name]}"
        puts "   Errors: #{area_of_concern.errors.full_messages.join(', ')}"
      end
    end
    
    puts " #{AreaOfConcern.count} areas of concern"
  end
end