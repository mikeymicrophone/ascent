class PolicySeeder
  def self.seed
    # Create policies that connect governing bodies to areas of concern through specific approaches
    policy_configurations = [
      # Federal Level Policies
      {
        governing_body: "United States Congress",
        area_of_concern: "Transportation Infrastructure",
        approach: "Infrastructure Investment Bond Program",
        title: "Federal Infrastructure Investment Act",
        description: "Comprehensive federal legislation providing $1.2 trillion over 10 years for transportation infrastructure, including roads, bridges, airports, ports, and public transit systems. Includes dedicated funding for rural connectivity and climate resilience.",
        status: "active",
        enacted_date: 2.years.ago
      },
      {
        governing_body: "United States Congress", 
        area_of_concern: "Environmental Protection",
        approach: "Comprehensive Environmental Monitoring and Enforcement",
        title: "Clean Air and Water Protection Act",
        description: "Federal legislation strengthening environmental protection standards, increasing EPA enforcement authority, and providing funding for state and local environmental monitoring and cleanup programs.",
        status: "active",
        enacted_date: 18.months.ago
      },
      
      # State Level Policies
      {
        governing_body: "California State Legislature",
        area_of_concern: "Education Policy", 
        approach: "State Funding Formula Reform",
        title: "Education Funding Equity Act",
        description: "State legislation reforming school funding formulas to ensure equitable per-pupil funding across all districts, with additional weighted funding for students with special needs, English language learners, and low-income students.",
        status: "active",
        enacted_date: 3.years.ago
      },
      {
        governing_body: "Office of the Governor of California",
        area_of_concern: "Healthcare Services",
        approach: "Mobile Health Clinic Network", 
        title: "Rural Healthcare Access Initiative",
        description: "Governor's executive order establishing mobile health clinic network serving rural counties, expanding telemedicine infrastructure, and providing loan forgiveness for healthcare providers serving underserved areas.",
        status: "active",
        enacted_date: 2.years.ago
      },
      {
        governing_body: "New York State Legislature",
        area_of_concern: "Housing & Urban Development",
        approach: "Housing Trust Fund Development",
        title: "Statewide Housing Trust Fund",
        description: "Legislation creating dedicated revenue stream for affordable housing through real estate transfer tax, providing grants and loans for affordable housing development, and establishing tenant protection standards.",
        status: "active", 
        enacted_date: 4.years.ago
      },
      
      # Municipal Level Policies
      {
        governing_body: "San Francisco City Council",
        area_of_concern: "Transportation Infrastructure",
        approach: "Complete Streets Infrastructure Upgrade",
        title: "Complete Streets Ordinance",
        description: "Municipal ordinance requiring all new street construction and major renovations to accommodate pedestrians, cyclists, transit users, and vehicles. Includes design standards, implementation timeline, and funding mechanisms.",
        status: "active",
        enacted_date: 3.years.ago
      },
      {
        governing_body: "Los Angeles City Council",
        area_of_concern: "Housing & Urban Development", 
        approach: "Inclusionary Housing Ordinance",
        title: "Affordable Housing Inclusion Requirements",
        description: "Ordinance requiring new residential developments of 10+ units to include 15% affordable housing or pay in-lieu fees. Provides density bonuses and expedited permitting for developments exceeding requirements.",
        status: "active",
        enacted_date: 2.years.ago
      },
      {
        governing_body: "Austin City Council",
        area_of_concern: "Environmental Protection",
        approach: "Climate Resilience and Adaptation Plan",
        title: "Climate Action and Resilience Plan",
        description: "Comprehensive municipal policy establishing greenhouse gas reduction targets, renewable energy requirements, green building standards, and climate adaptation measures for city infrastructure.",
        status: "active",
        enacted_date: 18.months.ago
      },
      {
        governing_body: "Miami City Council",
        area_of_concern: "Economic Development",
        approach: "Small Business Support and Development Program", 
        title: "Local Business Development Incentives",
        description: "Municipal program providing tax incentives, fee reductions, technical assistance, and preferential procurement opportunities for local small businesses. Includes performance requirements and monitoring.",
        status: "active",
        enacted_date: 2.years.ago
      },
      {
        governing_body: "San Francisco City Council",
        area_of_concern: "Public Safety",
        approach: "Community Policing and Neighborhood Engagement",
        title: "Community Safety and Accountability Act", 
        description: "Ordinance establishing community policing requirements, civilian oversight board, police accountability measures, and community engagement protocols. Includes bias training and de-escalation requirements.",
        status: "active",
        enacted_date: 1.year.ago
      },
      
      # County Level Policies
      {
        governing_body: "San Francisco County Executive",
        area_of_concern: "Social Services",
        approach: "Comprehensive Senior Services Center",
        title: "Aging in Place Support Program",
        description: "County initiative providing home modification assistance, transportation services, meal programs, and healthcare coordination to help seniors remain safely in their homes as they age.",
        status: "active",
        enacted_date: 2.years.ago
      },
      {
        governing_body: "Los Angeles County Executive",
        area_of_concern: "Healthcare Services",
        approach: "Integrated Community Mental Health System",
        title: "Universal Healthcare Access Initiative", 
        description: "County program expanding community health centers, providing sliding-scale fee structures, and coordinating with state Medicaid programs to ensure healthcare access for all residents regardless of insurance status.",
        status: "active",
        enacted_date: 3.years.ago
      },
      
      # Special District Policies
      {
        governing_body: "San Francisco Unified School District Board",
        area_of_concern: "Education Policy",
        approach: "Comprehensive Early Childhood Initiative",
        title: "Universal Pre-K and Early Learning Program",
        description: "School district policy establishing universal pre-kindergarten for all 4-year-olds, expanded early childhood programs, and family support services to ensure school readiness and close achievement gaps.",
        status: "active",
        enacted_date: 2.years.ago
      },
      {
        governing_body: "San Francisco Bay Area Rapid Transit District Board",
        area_of_concern: "Transportation Infrastructure",
        approach: "Bus Rapid Transit System",
        title: "Regional Bus Rapid Transit Implementation",
        description: "Transit authority policy implementing bus rapid transit with dedicated lanes, level boarding, real-time information systems, and integration with existing transit networks to improve service reliability and ridership.",
        status: "active",
        enacted_date: 18.months.ago
      },
      {
        governing_body: "Metropolitan Water District of Southern California Board", 
        area_of_concern: "Environmental Protection",
        approach: "Watershed Protection and Restoration Program",
        title: "Water Quality Protection Standards",
        description: "District policy establishing watershed protection measures, stormwater management requirements, and water quality monitoring to ensure safe drinking water and environmental protection.",
        status: "active",
        enacted_date: 3.years.ago
      },
      
      # Proposed and Under Review Policies
      {
        governing_body: "Austin City Council",
        area_of_concern: "Technology & Innovation",
        approach: "Municipal Broadband Infrastructure",
        title: "Digital Equity and Broadband Access Plan",
        description: "Proposed municipal broadband network providing high-speed internet access to underserved areas, digital literacy programs, and technology support for low-income residents.",
        status: "proposed",
        enacted_date: nil
      },
      {
        governing_body: "Texas State Legislature",
        area_of_concern: "Immigration & Integration", 
        approach: "Intergenerational Community Programs",
        title: "New American Integration Services Act",
        description: "Proposed state legislation providing English language classes, job training, citizenship assistance, and community integration support for new immigrants and refugees.",
        status: "under_review",
        enacted_date: nil
      },
      {
        governing_body: "Miami-Dade County Executive",
        area_of_concern: "Arts & Culture",
        approach: "Public-Private Arts Partnership",
        title: "Cultural Heritage Preservation Initiative",
        description: "Policy under review to establish partnerships with private organizations for cultural programming, historic preservation, and arts education, with dedicated funding and community engagement requirements.",
        status: "under_review", 
        enacted_date: nil
      },
      
      # Repealed Policy Example
      {
        governing_body: "Miami City Council",
        area_of_concern: "Transportation Infrastructure",
        approach: "Complete Streets Infrastructure Upgrade",
        title: "Minimum Parking Requirements (Repealed)",
        description: "Former policy requiring minimum parking spaces for all developments. Repealed to encourage transit-oriented development, reduce housing costs, and promote sustainable transportation options.",
        status: "repealed",
        enacted_date: 8.years.ago,
        expiration_date: 2.years.ago
      }
    ]
    
    policy_configurations.each do |config|
      # Find governing body by name
      governing_body = GoverningBody.find_by(name: config[:governing_body])
      unless governing_body
        puts "\n❌ Governing body not found: #{config[:governing_body]}"
        next
      end
      
      # Find area of concern by name
      area_of_concern = AreaOfConcern.find_by(name: config[:area_of_concern])
      unless area_of_concern
        puts "\n❌ Area of concern not found: #{config[:area_of_concern]}"
        next
      end
      
      # Find approach by title
      approach = Approach.find_by(title: config[:approach])
      unless approach
        puts "\n❌ Approach not found: #{config[:approach]}"
        next
      end
      
      # Create the policy
      policy = Policy.find_or_create_by(
        title: config[:title],
        governing_body: governing_body
      ) do |p|
        p.area_of_concern = area_of_concern
        p.approach = approach
        p.description = config[:description]
        p.status = config[:status]
        p.enacted_date = config[:enacted_date]
        p.expiration_date = config[:expiration_date]
      end
      
      if policy.persisted?
        print "."
      else
        puts "\n❌ Failed to create policy: #{config[:title]}"
        puts "   Errors: #{policy.errors.full_messages.join(', ')}"
      end
    end
    
    puts " #{Policy.count} policies"
  end
end