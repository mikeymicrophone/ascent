class IssueSeeder
  def self.seed
    # Map issues to their topics
    issues_by_topic = {
      "Education" => [
        {
          title: "School Funding Shortfalls",
          description: "Inadequate per-pupil funding is resulting in larger class sizes, outdated textbooks, deferred maintenance, elimination of music and arts programs, and difficulty recruiting and retaining qualified teachers, particularly in high-need districts."
        },
        {
          title: "Student Achievement Gaps",
          description: "Persistent disparities in academic performance between different demographic groups, with students from low-income families and certain racial/ethnic backgrounds consistently scoring lower on standardized tests and graduating at lower rates."
        },
        {
          title: "Teacher Shortage Crisis",
          description: "Critical shortage of qualified teachers, especially in math, science, special education, and bilingual education, leading to increased use of substitute teachers, larger class sizes, and some classes being cancelled or combined."
        },
        {
          title: "School Infrastructure Decay",
          description: "Aging school buildings with failing HVAC systems, leaking roofs, outdated technology infrastructure, and accessibility issues that create unsafe learning environments and barriers to modern educational methods."
        }
      ],
      "Healthcare" => [
        {
          title: "Rural Healthcare Access",
          description: "Limited access to healthcare services in rural areas due to hospital closures, physician shortages, and inadequate transportation, forcing residents to travel long distances for basic medical care and emergency services."
        },
        {
          title: "Mental Health Service Gaps",
          description: "Insufficient mental health services and long waiting lists for counseling and psychiatric care, particularly for children, adolescents, and low-income residents, contributing to untreated mental illness and community health crises."
        },
        {
          title: "Healthcare Affordability Crisis",
          description: "Rising healthcare costs and insurance premiums are making medical care unaffordable for middle-class families, leading to delayed treatment, medical debt, and people foregoing necessary medications and procedures."
        },
        {
          title: "Public Health Emergency Preparedness",
          description: "Inadequate preparation for disease outbreaks, natural disasters, and health emergencies, including insufficient emergency medical supplies, coordination systems, and public health communication capabilities."
        }
      ],
      "Housing & Development" => [
        {
          title: "Affordable Housing Shortage",
          description: "Severe shortage of affordable housing units has resulted in working families spending more than 30% of income on housing, increased homelessness, and young adults unable to purchase homes in their communities."
        },
        {
          title: "Homelessness Crisis",
          description: "Rising numbers of individuals and families experiencing homelessness, with insufficient emergency shelter capacity, supportive services, and permanent housing solutions, particularly affecting veterans and mentally ill individuals."
        },
        {
          title: "Gentrification and Displacement",
          description: "Rapid neighborhood development is displacing long-term residents and small businesses through rising property values and rents, eroding community character and forcing out families who have lived in areas for generations."
        },
        {
          title: "Zoning and Development Barriers",
          description: "Outdated zoning laws and lengthy permitting processes are preventing development of mixed-income housing, transit-oriented development, and adaptive reuse projects that could address housing needs more effectively."
        }
      ],
      "Transportation" => [
        {
          title: "Traffic Congestion",
          description: "Chronic traffic congestion during peak hours increases commute times, air pollution, fuel costs, and economic productivity losses, while creating safety hazards and reducing quality of life for residents."
        },
        {
          title: "Public Transit Inadequacy",
          description: "Limited public transportation options with infrequent service, poor route coverage, and unreliable schedules that fail to serve low-income residents and reduce car dependency effectively."
        },
        {
          title: "Pedestrian and Bicycle Safety",
          description: "High rates of pedestrian and cyclist injuries and fatalities due to inadequate sidewalks, bike lanes, crosswalks, and traffic calming measures, particularly near schools and in dense neighborhoods."
        },
        {
          title: "Transportation Infrastructure Deterioration",
          description: "Crumbling roads, bridges, and transit infrastructure requiring costly repairs and creating safety hazards, with insufficient funding for systematic maintenance and modern upgrades."
        }
      ],
      "Environment & Sustainability" => [
        {
          title: "Climate Change Impacts",
          description: "Increasing frequency of extreme weather events, rising temperatures, and changing precipitation patterns are affecting local agriculture, increasing energy costs, and threatening community resilience and economic stability."
        },
        {
          title: "Air and Water Pollution",
          description: "Industrial emissions, vehicle exhaust, agricultural runoff, and waste discharge are contaminating local air and water sources, creating health risks and degrading environmental quality for residents."
        },
        {
          title: "Waste Management Challenges",
          description: "Increasing waste generation, limited recycling programs, and rising disposal costs are straining waste management systems, while plastic pollution and organic waste contribute to environmental degradation."
        },
        {
          title: "Loss of Green Spaces",
          description: "Urban development is eliminating parks, forests, and natural areas that provide environmental benefits, recreation opportunities, and habitat for wildlife, reducing community livability and environmental resilience."
        }
      ],
      "Public Safety" => [
        {
          title: "Rising Crime Rates",
          description: "Increases in property crime, violent crime, and drug-related offenses in certain neighborhoods are creating safety concerns for residents and businesses, requiring comprehensive intervention strategies."
        },
        {
          title: "Emergency Response Times",
          description: "Longer response times for police, fire, and emergency medical services due to budget constraints, staffing shortages, and increasing call volumes, potentially putting lives and property at risk."
        },
        {
          title: "Community-Police Relations",
          description: "Strained relationships between law enforcement and certain communities, particularly communities of color, leading to reduced trust, cooperation, and effectiveness of policing efforts."
        },
        {
          title: "Substance Abuse and Addiction",
          description: "Opioid crisis and substance abuse problems are overwhelming treatment capacity, increasing crime rates, and straining emergency services, while families struggle to find help for addicted relatives."
        }
      ],
      "Economic Development" => [
        {
          title: "High Unemployment",
          description: "Persistent unemployment in certain demographics and geographic areas limits economic mobility, reduces tax revenue, and contributes to social problems, while available jobs often don't match worker skills."
        },
        {
          title: "Small Business Struggles",
          description: "Small businesses face challenges with high commercial rents, complex regulations, limited access to capital, and competition from large chains and online retailers, leading to reduced local entrepreneurship."
        },
        {
          title: "Skills Gap in Workforce",
          description: "Mismatch between available jobs requiring technical skills and workforce training, leaving positions unfilled while workers lack opportunities for career advancement in growing industries."
        },
        {
          title: "Downtown Economic Decline",
          description: "Historic downtown areas struggling with vacant storefronts, reduced foot traffic, and competition from suburban shopping centers, undermining community identity and local economic vitality."
        }
      ],
      "Social Services" => [
        {
          title: "Senior Care Service Gaps",
          description: "Growing senior population lacks adequate access to home healthcare, transportation services, social activities, and affordable assisted living options, while many seniors struggle to age in place safely."
        },
        {
          title: "Child Welfare System Strain",
          description: "Overburdened child protective services with high caseloads, insufficient foster families, and limited resources for family support services, putting vulnerable children at risk."
        },
        {
          title: "Food Insecurity",
          description: "Significant numbers of families, including working families, experience food insecurity due to high costs, limited access to grocery stores, and insufficient support programs, affecting children's health and academic performance."
        },
        {
          title: "Disability Services Inadequacy",
          description: "Insufficient services and support for individuals with disabilities, including limited accessible housing, employment opportunities, transportation, and community integration programs."
        }
      ],
      "Infrastructure & Technology" => [
        {
          title: "Digital Divide",
          description: "Unequal access to high-speed internet and modern technology creates educational and economic disadvantages for low-income families, rural residents, and seniors, limiting opportunities for online learning and remote work."
        },
        {
          title: "Aging Water and Sewer Systems",
          description: "Deteriorating water and wastewater infrastructure leads to service disruptions, water quality issues, and environmental contamination, while requiring massive capital investment for repairs and upgrades."
        },
        {
          title: "Cybersecurity Vulnerabilities",
          description: "Government systems and critical infrastructure face increasing cybersecurity threats that could disrupt essential services, compromise citizen data, and damage public trust in digital government services."
        },
        {
          title: "Energy Grid Reliability",
          description: "Aging electrical grid infrastructure struggles with increasing demand, extreme weather events, and integration of renewable energy sources, leading to power outages and reliability concerns."
        }
      ],
      "Arts, Culture & Recreation" => [
        {
          title: "Cultural Funding Shortfalls",
          description: "Reduced funding for arts programs, cultural organizations, and community events limits creative opportunities for residents, particularly youth, and diminishes community cultural vitality and identity."
        },
        {
          title: "Historic Preservation Challenges",
          description: "Historic buildings and cultural landmarks face demolition pressure from development, lack of maintenance funding, and regulatory barriers to adaptive reuse, threatening community heritage and character."
        },
        {
          title: "Recreation Facility Inadequacy",
          description: "Insufficient parks, recreational facilities, and youth programs limit opportunities for physical activity, social interaction, and healthy lifestyle choices, particularly in underserved neighborhoods."
        },
        {
          title: "Library Service Limitations",
          description: "Budget constraints force reduced library hours, outdated technology, limited programming, and staff reductions, reducing access to information, educational support, and community gathering spaces."
        }
      ]
    }
    
    issues_by_topic.each do |topic_title, issues|
      topic = Topic.find_by(title: topic_title)
      unless topic
        puts "\n❌ Topic not found: #{topic_title}"
        next
      end
      
      issues.each do |issue_attrs|
        issue = Issue.find_or_create_by(title: issue_attrs[:title], topic: topic) do |i|
          i.description = issue_attrs[:description]
        end
        
        if issue.persisted?
          print "."
        else
          puts "\n❌ Failed to create issue: #{issue_attrs[:title]}"
          puts "   Errors: #{issue.errors.full_messages.join(', ')}"
        end
      end
    end
    
    puts " #{Issue.count} issues"
  end
end