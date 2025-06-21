class ApproachSeeder
  def self.seed
    # Map approaches to their issues
    approaches_by_issue = {
      "School Funding Shortfalls" => [
        {
          title: "Education Revenue Bond Initiative",
          description: "Issue municipal bonds dedicated to education funding, allowing voters to approve additional property tax revenue specifically for schools, with transparent oversight and regular reporting on fund usage and educational outcomes."
        },
        {
          title: "State Funding Formula Reform",
          description: "Advocate for state-level changes to per-pupil funding formulas that account for local cost of living, special needs populations, and equity adjustments, while lobbying for increased overall state education investment."
        },
        {
          title: "Corporate Education Partnership Program",
          description: "Establish formal partnerships with local businesses to provide direct funding, equipment donations, internship programs, and professional mentoring, creating sustainable private sector investment in public education."
        }
      ],
      "Student Achievement Gaps" => [
        {
          title: "Comprehensive Early Childhood Initiative",
          description: "Implement universal pre-K programs, expand head start enrollment, provide family literacy support, and create seamless transitions from early childhood programs to elementary school to address achievement gaps before they widen."
        },
        {
          title: "Targeted Academic Support Program",
          description: "Deploy additional tutoring, extended learning time, summer programs, and individualized support specifically for underperforming student populations, with data-driven tracking and culturally responsive teaching methods."
        },
        {
          title: "Community Schools Model",
          description: "Transform schools into community hubs offering wraparound services including healthcare, social services, adult education, and family support to address socioeconomic barriers to student achievement."
        }
      ],
      "Teacher Shortage Crisis" => [
        {
          title: "Teacher Recruitment and Retention Initiative",
          description: "Increase teacher salaries to competitive regional levels, provide signing bonuses for high-need subjects, offer loan forgiveness programs, and create affordable housing assistance for educators to attract and retain quality teachers."
        },
        {
          title: "Alternative Certification Pathways",
          description: "Develop fast-track certification programs for career professionals, expanded master's degree programs with teaching components, and partnerships with universities to create innovative teacher preparation routes."
        },
        {
          title: "Comprehensive Teacher Support System",
          description: "Implement robust mentoring programs, reduce non-teaching administrative burdens, provide professional development stipends, and create collaborative planning time to improve working conditions and job satisfaction."
        }
      ],
      "School Infrastructure Decay" => [
        {
          title: "Systematic Infrastructure Assessment and Repair",
          description: "Conduct comprehensive facility audits, prioritize safety and health-critical repairs, establish dedicated maintenance funding streams, and implement preventive maintenance schedules to address deferred maintenance systematically."
        },
        {
          title: "21st Century Learning Environments Initiative",
          description: "Modernize classrooms with updated technology infrastructure, flexible learning spaces, improved acoustics and lighting, and energy-efficient systems that support contemporary teaching methods and reduce operational costs."
        },
        {
          title: "School Construction Public-Private Partnership",
          description: "Partner with private developers to build new schools or renovate existing ones through long-term lease agreements, allowing immediate improvements while spreading costs over time through performance-based contracts."
        }
      ],
      "Rural Healthcare Access" => [
        {
          title: "Mobile Health Clinic Network",
          description: "Deploy mobile health units staffed with nurse practitioners and physicians to provide regular primary care, preventive services, and specialist consultations to rural communities, with telemedicine capabilities for remote diagnosis."
        },
        {
          title: "Rural Healthcare Provider Incentive Program",
          description: "Offer medical school loan forgiveness, housing assistance, competitive salaries, and professional development opportunities to attract physicians, nurses, and specialists to practice in underserved rural areas."
        },
        {
          title: "Regional Healthcare Collaboration Hub",
          description: "Create partnerships between rural hospitals, urban medical centers, and specialty clinics to share resources, provide telemedicine consultations, and coordinate patient transfers for specialized care."
        }
      ],
      "Mental Health Service Gaps" => [
        {
          title: "Integrated Community Mental Health System",
          description: "Establish community mental health centers offering comprehensive services from crisis intervention to long-term therapy, with sliding fee scales, peer support programs, and coordination with primary healthcare providers."
        },
        {
          title: "School-Based Mental Health Services",
          description: "Place licensed mental health counselors in schools to provide immediate access to services for students, offer family counseling, implement mental health education curricula, and train teachers in trauma-informed practices."
        },
        {
          title: "Telehealth Mental Health Expansion",
          description: "Expand access to mental health services through teletherapy platforms, online counseling programs, and virtual support groups, particularly targeting underserved populations and reducing geographic barriers to care."
        }
      ],
      "Healthcare Affordability Crisis" => [
        {
          title: "Municipal Healthcare Purchasing Cooperative",
          description: "Join or create regional purchasing cooperatives to negotiate better rates for prescription drugs, medical supplies, and insurance premiums, leveraging collective bargaining power to reduce costs for residents and employers."
        },
        {
          title: "Sliding Scale Community Health Program",
          description: "Establish income-based fee structures for municipal health services, expand community health center capacity, and provide prescription assistance programs for low and middle-income families."
        },
        {
          title: "Healthcare Cost Transparency Initiative",
          description: "Require healthcare providers to publish transparent pricing, support price comparison tools, and advocate for state and federal legislation limiting surprise billing and promoting healthcare cost transparency."
        }
      ],
      "Public Health Emergency Preparedness" => [
        {
          title: "Comprehensive Emergency Response System",
          description: "Develop integrated emergency response plans with hospitals, first responders, and public health agencies, maintain strategic medical supply reserves, and conduct regular emergency preparedness drills and training exercises."
        },
        {
          title: "Public Health Communication Network",
          description: "Create multi-channel communication systems for health emergencies, including social media, mobile alerts, community liaisons, and multilingual messaging to ensure rapid and accurate information dissemination to all residents."
        },
        {
          title: "Regional Health Security Partnership",
          description: "Coordinate with neighboring jurisdictions, state agencies, and federal resources to create regional response capacity, share emergency resources, and develop mutual aid agreements for major health emergencies."
        }
      ],
      "Affordable Housing Shortage" => [
        {
          title: "Inclusionary Housing Ordinance",
          description: "Require new residential developments to include a percentage of affordable units or pay in-lieu fees, while providing density bonuses and fast-track permitting for developers who exceed affordable housing requirements."
        },
        {
          title: "Community Land Trust Program",
          description: "Establish community land trusts to maintain permanent affordable housing, provide shared equity homeownership programs, and prevent gentrification by keeping land in community ownership while enabling resident homeownership."
        },
        {
          title: "Housing Trust Fund Development",
          description: "Create dedicated revenue streams through real estate transfer taxes, development impact fees, or bond measures to fund affordable housing development, down payment assistance, and rental subsidy programs."
        }
      ],
      "Homelessness Crisis" => [
        {
          title: "Housing First Initiative",
          description: "Implement housing first approach providing immediate permanent housing without preconditions, combined with wraparound services including mental health treatment, substance abuse counseling, and job training programs."
        },
        {
          title: "Comprehensive Prevention and Rapid Rehousing",
          description: "Develop prevention programs to help at-risk families avoid eviction, provide emergency rental assistance, and create rapid rehousing programs that quickly move homeless individuals into permanent housing with short-term support."
        },
        {
          title: "Coordinated Regional Homelessness Response",
          description: "Create coordinated entry systems across the region, standardize data collection and tracking, and pool resources among jurisdictions to provide seamless services and eliminate duplication of efforts."
        }
      ],
      "Gentrification and Displacement" => [
        {
          title: "Anti-Displacement Protection Program",
          description: "Implement tenant protection ordinances including just-cause eviction requirements, rent stabilization measures, and relocation assistance for displaced residents, while preserving existing affordable housing stock."
        },
        {
          title: "Community Benefit Agreements",
          description: "Require developers of major projects to negotiate community benefit agreements ensuring local hiring, affordable housing inclusion, small business protection, and community facility improvements that benefit existing residents."
        },
        {
          title: "Cultural Heritage Preservation Initiative",
          description: "Protect culturally significant businesses and institutions through commercial rent stabilization, facade improvement grants, and zoning protections that maintain neighborhood character while allowing appropriate development."
        }
      ],
      "Zoning and Development Barriers" => [
        {
          title: "Zoning Code Modernization",
          description: "Update zoning codes to allow mixed-use development, reduce parking requirements, enable accessory dwelling units, and streamline approval processes for sustainable and affordable housing development."
        },
        {
          title: "Development Fast-Track Program",
          description: "Create expedited permitting processes for projects meeting affordability, sustainability, or community benefit criteria, with dedicated staff, clear timelines, and reduced fees to incentivize desired development types."
        },
        {
          title: "Form-Based Zoning Implementation",
          description: "Replace traditional use-based zoning with form-based codes that focus on building design and pedestrian-friendly development, enabling more flexible and context-sensitive development patterns."
        }
      ],
      "Traffic Congestion" => [
        {
          title: "Intelligent Transportation Management System",
          description: "Implement adaptive traffic signal systems, real-time traffic monitoring, and coordinated signal timing to optimize traffic flow, reduce wait times, and improve overall transportation efficiency throughout the network."
        },
        {
          title: "Congestion Pricing and Demand Management",
          description: "Introduce congestion pricing in high-traffic areas during peak hours, promote flexible work schedules, enhance carpooling programs, and incentivize off-peak travel to reduce traffic volume during rush hours."
        },
        {
          title: "Complete Streets Infrastructure Upgrade",
          description: "Redesign streets to accommodate multiple transportation modes including dedicated bus lanes, protected bike lanes, wider sidewalks, and transit signal priority to provide alternatives to single-occupancy vehicle travel."
        }
      ],
      "Public Transit Inadequacy" => [
        {
          title: "Bus Rapid Transit System",
          description: "Develop bus rapid transit with dedicated lanes, level boarding, off-board fare payment, and frequent service to provide fast, reliable transit that rivals rail systems at lower cost and with greater route flexibility."
        },
        {
          title: "Transit Service Expansion and Improvement",
          description: "Increase bus frequency, extend service hours, add routes to underserved areas, and upgrade bus stops with real-time arrival information, weather protection, and improved accessibility features."
        },
        {
          title: "Integrated Mobility Hub Network",
          description: "Create multimodal transportation hubs connecting bus, rail, bike share, ride share, and pedestrian facilities with seamless transfers, unified payment systems, and complementary services like retail and charging stations."
        }
      ],
      "Pedestrian and Bicycle Safety" => [
        {
          title: "Vision Zero Safety Initiative",
          description: "Implement comprehensive Vision Zero program with traffic calming measures, protected bike lanes, improved crosswalks, speed limit reductions, and enhanced enforcement to eliminate traffic fatalities and serious injuries."
        },
        {
          title: "Safe Routes to School Program",
          description: "Create safe walking and biking routes to schools through infrastructure improvements, crossing guards, safety education, and encouragement programs that reduce vehicle traffic and promote active transportation for students."
        },
        {
          title: "Complete Bicycle Infrastructure Network",
          description: "Build connected network of protected bike lanes, multi-use trails, secure bike parking, and maintenance stations to create safe, convenient cycling infrastructure that serves commuters and recreational users."
        }
      ],
      "Transportation Infrastructure Deterioration" => [
        {
          title: "Asset Management and Systematic Maintenance",
          description: "Implement data-driven asset management systems to prioritize infrastructure investments, establish predictive maintenance schedules, and secure dedicated funding streams for systematic repair and replacement programs."
        },
        {
          title: "Infrastructure Investment Bond Program",
          description: "Issue infrastructure bonds to fund major transportation improvements, leveraging federal and state matching funds, and implementing transparent project prioritization based on safety, economic impact, and community needs."
        },
        {
          title: "Public-Private Infrastructure Partnership",
          description: "Partner with private entities for infrastructure financing and management through long-term concession agreements, allowing immediate improvements while transferring maintenance responsibility and risk to experienced operators."
        }
      ],
      "Climate Change Impacts" => [
        {
          title: "Climate Resilience and Adaptation Plan",
          description: "Develop comprehensive climate adaptation strategies including flood management, heat island reduction, drought preparedness, and ecosystem restoration to protect community infrastructure and public health from climate impacts."
        },
        {
          title: "Renewable Energy Transition Initiative",
          description: "Accelerate renewable energy adoption through municipal clean energy programs, solar panel incentives, energy storage systems, and partnerships with utilities to achieve carbon neutrality goals."
        },
        {
          title: "Green Infrastructure Development",
          description: "Implement natural solutions like urban forests, green roofs, rain gardens, and permeable pavements to manage stormwater, reduce urban heat, improve air quality, and enhance community resilience to climate change."
        }
      ],
      "Air and Water Pollution" => [
        {
          title: "Comprehensive Environmental Monitoring and Enforcement",
          description: "Expand environmental monitoring capabilities, strengthen enforcement of pollution regulations, implement regular inspections of industrial facilities, and establish real-time pollution tracking systems with public reporting."
        },
        {
          title: "Clean Transportation and Energy Initiative",
          description: "Promote electric vehicle adoption through charging infrastructure, convert municipal fleet to clean vehicles, incentivize clean energy use, and support businesses transitioning to sustainable practices."
        },
        {
          title: "Watershed Protection and Restoration Program",
          description: "Implement watershed management strategies including riparian buffer zones, stormwater management, agricultural runoff controls, and habitat restoration to protect water quality and ecosystem health."
        }
      ],
      "Waste Management Challenges" => [
        {
          title: "Zero Waste Initiative",
          description: "Implement comprehensive waste reduction program including expanded recycling, composting programs, single-use plastic bans, producer responsibility legislation, and public education to minimize waste generation."
        },
        {
          title: "Circular Economy Development",
          description: "Promote circular economy principles through material recovery facilities, business waste reduction incentives, repair and reuse programs, and partnerships that turn waste streams into economic opportunities."
        },
        {
          title: "Advanced Waste Processing Technology",
          description: "Invest in modern waste processing technologies including anaerobic digestion, advanced recycling systems, and waste-to-energy facilities to maximize resource recovery and minimize landfill disposal."
        }
      ],
      "Loss of Green Spaces" => [
        {
          title: "Urban Forest and Parks Expansion",
          description: "Acquire and preserve open spaces through park bonds, conservation easements, and land banking programs, while implementing tree planting initiatives and creating pocket parks in dense urban areas."
        },
        {
          title: "Green Development Standards",
          description: "Require new developments to include green space, preserve existing trees, and provide environmental impact mitigation through on-site or off-site conservation measures and green building requirements."
        },
        {
          title: "Community Garden and Urban Agriculture",
          description: "Support community gardens, urban farms, and food forests that provide green space, local food production, educational opportunities, and community gathering places while improving environmental quality."
        }
      ],
      "Rising Crime Rates" => [
        {
          title: "Community Policing and Neighborhood Engagement",
          description: "Implement community policing strategies with dedicated neighborhood officers, regular community meetings, civilian review boards, and partnerships between police and residents to build trust and prevent crime collaboratively."
        },
        {
          title: "Crime Prevention Through Environmental Design",
          description: "Improve public spaces through better lighting, clear sightlines, maintained landscaping, and activated public areas to reduce crime opportunities while creating more inviting and safer community environments."
        },
        {
          title: "Comprehensive Violence Intervention Program",
          description: "Deploy evidence-based violence intervention strategies including conflict mediation, gang outreach programs, trauma-informed services, and economic opportunities for at-risk individuals to address root causes of crime."
        }
      ],
      "Emergency Response Times" => [
        {
          title: "Emergency Services Optimization",
          description: "Analyze response data to optimize station locations, implement dynamic deployment strategies, cross-train personnel for multiple emergency types, and use predictive analytics to pre-position resources during high-demand periods."
        },
        {
          title: "Regional Emergency Services Cooperation",
          description: "Develop mutual aid agreements with neighboring jurisdictions, share specialized equipment and personnel, coordinate dispatch systems, and create regional training programs to improve overall emergency response capacity."
        },
        {
          title: "Technology-Enhanced Emergency Response",
          description: "Implement advanced dispatch systems, GPS tracking for emergency vehicles, mobile data terminals, and communication technology upgrades to improve coordination, reduce response times, and enhance situational awareness."
        }
      ],
      "Community-Police Relations" => [
        {
          title: "Police Accountability and Transparency Initiative",
          description: "Establish civilian oversight committees, implement body camera programs, create transparent complaint processes, and require de-escalation training to improve police accountability and build community trust."
        },
        {
          title: "Community Engagement and Cultural Competency",
          description: "Mandate cultural competency training, hire officers reflecting community demographics, establish regular police-community dialogue forums, and create youth engagement programs to improve police-community relationships."
        },
        {
          title: "Restorative Justice and Alternative Response",
          description: "Implement restorative justice programs, deploy mental health crisis response teams, create pre-arrest diversion programs, and use community mediation to address conflicts without traditional criminal justice involvement."
        }
      ],
      "Substance Abuse and Addiction" => [
        {
          title: "Comprehensive Addiction Treatment System",
          description: "Expand addiction treatment capacity through residential and outpatient programs, medication-assisted treatment, peer support services, and integration with mental health and social services for holistic recovery support."
        },
        {
          title: "Harm Reduction and Public Health Approach",
          description: "Implement harm reduction strategies including needle exchange programs, overdose prevention sites, naloxone distribution, and treating addiction as a public health issue rather than solely a criminal justice matter."
        },
        {
          title: "Prevention and Early Intervention",
          description: "Develop comprehensive prevention programs in schools and communities, provide early intervention services for at-risk individuals, and create family support programs to prevent substance abuse before it develops."
        }
      ],
      "High Unemployment" => [
        {
          title: "Workforce Development and Skills Training",
          description: "Partner with employers to provide job training in high-demand industries, establish apprenticeship programs, upgrade community college facilities, and create career pathway programs for unemployed and underemployed residents."
        },
        {
          title: "Local Hiring and Procurement Initiative",
          description: "Implement local hiring requirements for public projects, provide preferences for local businesses in government contracting, and create programs connecting unemployed residents with local job opportunities and training."
        },
        {
          title: "Entrepreneurship and Small Business Support",
          description: "Establish business incubators, provide microloans and technical assistance for startups, create one-stop permitting processes, and offer entrepreneurship training to help residents create their own employment opportunities."
        }
      ],
      "Small Business Struggles" => [
        {
          title: "Small Business Support and Development Program",
          description: "Provide technical assistance, access to capital through loan funds, business mentoring programs, and reduced regulatory barriers to help small businesses start, grow, and compete effectively in the local market."
        },
        {
          title: "Commercial District Revitalization",
          description: "Invest in commercial area improvements, provide facade grants, organize business association support, implement parking solutions, and create events and marketing to drive customer traffic to local businesses."
        },
        {
          title: "Buy Local and Business Retention Initiative",
          description: "Launch buy local campaigns, provide marketing support for local businesses, create business loyalty programs, and establish policies that support local business retention and expansion over chain store development."
        }
      ],
      "Skills Gap in Workforce" => [
        {
          title: "Industry-Education Partnership Program",
          description: "Create formal partnerships between educational institutions and local employers to align curriculum with job market needs, provide internships, and establish pathways from education to employment in growing industries."
        },
        {
          title: "Adult Education and Retraining Initiative",
          description: "Expand adult education programs, provide career counseling and skills assessment, offer flexible scheduling for working adults, and create stackable credentials that allow progressive skill building in high-demand fields."
        },
        {
          title: "Technology and Digital Literacy Program",
          description: "Address digital skills gaps through computer training programs, digital literacy classes, coding bootcamps, and partnerships with technology companies to prepare workers for the modern economy."
        }
      ],
      "Downtown Economic Decline" => [
        {
          title: "Downtown Revitalization and Mixed-Use Development",
          description: "Incentivize mixed-use development combining residential, commercial, and office space, improve pedestrian infrastructure, create public gathering spaces, and attract anchor businesses to drive foot traffic downtown."
        },
        {
          title: "Arts and Entertainment District Development",
          description: "Develop downtown as an arts and entertainment destination through venue development, artist live-work spaces, cultural events, and entertainment programming that draws visitors and creates economic activity."
        },
        {
          title: "Historic Preservation and Adaptive Reuse",
          description: "Preserve historic downtown buildings through tax incentives, grants for building improvements, and streamlined processes for adaptive reuse that maintains character while enabling modern commercial uses."
        }
      ],
      "Senior Care Service Gaps" => [
        {
          title: "Comprehensive Senior Services Center",
          description: "Establish multi-service senior centers offering healthcare, social services, meal programs, transportation, recreational activities, and educational opportunities in accessible locations throughout the community."
        },
        {
          title: "Aging in Place Support Program",
          description: "Provide home modification assistance, in-home care services, grocery delivery, transportation for medical appointments, and technology support to help seniors remain safely in their homes as they age."
        },
        {
          title: "Intergenerational Community Programs",
          description: "Create programs connecting seniors with younger generations through mentoring, skills sharing, and mutual support that reduces isolation while providing valuable services and knowledge exchange."
        }
      ],
      "Child Welfare System Strain" => [
        {
          title: "Family Preservation and Support Services",
          description: "Expand family support services including parenting classes, substance abuse treatment, mental health services, and economic assistance to address underlying issues and prevent children from entering foster care."
        },
        {
          title: "Foster Care System Improvement",
          description: "Recruit and support more foster families, provide enhanced training and ongoing support, improve placement stability, and create mentoring programs for youth aging out of foster care."
        },
        {
          title: "Child Welfare System Reform",
          description: "Reduce caseloads for social workers, implement trauma-informed practices, improve court processes, and create specialized courts for child welfare cases to improve outcomes for children and families."
        }
      ],
      "Food Insecurity" => [
        {
          title: "Community Food System Development",
          description: "Support food banks, establish mobile food pantries, create community gardens, and develop local food production and distribution systems to improve food access and reduce transportation barriers."
        },
        {
          title: "School and Summer Meal Program Expansion",
          description: "Expand free school meal programs, implement universal school meals, provide summer and weekend meal programs, and create mobile meal delivery to ensure children have consistent access to nutritious food."
        },
        {
          title: "Food Access and Affordability Initiative",
          description: "Attract grocery stores to underserved areas through incentives, support farmers markets accepting SNAP benefits, provide nutrition education, and create programs making healthy food more affordable for low-income families."
        }
      ],
      "Disability Services Inadequacy" => [
        {
          title: "Comprehensive Disability Services Program",
          description: "Expand disability services including job training and placement, accessible transportation, assistive technology, and independent living support to improve quality of life and community integration for people with disabilities."
        },
        {
          title: "Accessibility and Universal Design Initiative",
          description: "Ensure all public facilities meet accessibility standards, require universal design in new construction, provide accessibility improvements for existing buildings, and create accessible recreation and transportation options."
        },
        {
          title: "Disability Employment and Independence Program",
          description: "Create supported employment programs, provide job coaching and placement services, establish disabled-owned business support, and promote inclusive hiring practices among local employers."
        }
      ],
      "Digital Divide" => [
        {
          title: "Municipal Broadband Infrastructure",
          description: "Develop municipal broadband networks or partner with internet service providers to ensure high-speed internet access in underserved areas, with affordable rates and digital equity programs."
        },
        {
          title: "Digital Literacy and Device Access Program",
          description: "Provide computer and digital literacy training, establish device lending programs, offer technical support, and create public computer access points to ensure all residents can benefit from digital technology."
        },
        {
          title: "School and Community Technology Initiative",
          description: "Ensure all students have device and internet access for home learning, provide family technology training, and create community technology centers in libraries and community centers."
        }
      ],
      "Aging Water and Sewer Systems" => [
        {
          title: "Water Infrastructure Modernization Program",
          description: "Implement systematic replacement of aging water and sewer lines, upgrade treatment facilities, install smart water meters, and establish dedicated funding mechanisms for ongoing infrastructure maintenance and improvements."
        },
        {
          title: "Water Conservation and Efficiency Initiative",
          description: "Implement water conservation programs, provide rebates for efficient fixtures, establish tiered pricing structures, and develop alternative water sources to reduce demand on aging infrastructure while promoting sustainability."
        },
        {
          title: "Public-Private Water Infrastructure Partnership",
          description: "Partner with private utilities or engineering firms for infrastructure upgrades, operations, and maintenance through long-term agreements that provide immediate improvements while ensuring long-term system reliability."
        }
      ],
      "Cybersecurity Vulnerabilities" => [
        {
          title: "Comprehensive Cybersecurity Program",
          description: "Implement multi-layered cybersecurity defenses including firewalls, intrusion detection, employee training, regular security audits, and incident response plans to protect government systems and citizen data."
        },
        {
          title: "Regional Cybersecurity Collaboration",
          description: "Partner with other jurisdictions, state agencies, and federal resources to share threat intelligence, coordinate incident response, and access specialized cybersecurity expertise and resources."
        },
        {
          title: "Cybersecurity Awareness and Training",
          description: "Provide regular cybersecurity training for all government employees, implement strong password and access policies, and educate citizens about cybersecurity threats and safe digital practices."
        }
      ],
      "Energy Grid Reliability" => [
        {
          title: "Smart Grid and Energy Storage Initiative",
          description: "Upgrade electrical grid infrastructure with smart grid technology, battery storage systems, and improved monitoring and control systems to enhance reliability, integrate renewable energy, and respond to outages quickly."
        },
        {
          title: "Distributed Energy and Microgrids",
          description: "Develop distributed energy systems including solar panels, small wind systems, and microgrids for critical facilities to reduce grid dependence and provide backup power during emergencies."
        },
        {
          title: "Energy Efficiency and Demand Management",
          description: "Implement energy efficiency programs, smart building technologies, demand response systems, and time-of-use pricing to reduce peak demand and stress on the electrical grid while lowering costs for consumers."
        }
      ],
      "Cultural Funding Shortfalls" => [
        {
          title: "Public-Private Arts Partnership",
          description: "Create partnerships with businesses, foundations, and individual donors to supplement public arts funding, establish corporate sponsorship programs, and develop endowments for sustainable arts programming."
        },
        {
          title: "Creative Economy Development Initiative",
          description: "Support the creative economy through artist workspace development, creative business incubation, cultural tourism promotion, and policies that recognize and support arts and culture as economic drivers."
        },
        {
          title: "Community Arts Access Program",
          description: "Ensure arts access for all residents through sliding-scale programming, free community events, arts education in schools, and outreach programs that bring cultural activities to underserved neighborhoods."
        }
      ],
      "Historic Preservation Challenges" => [
        {
          title: "Historic Preservation Incentive Program",
          description: "Provide tax incentives, grants, and low-interest loans for historic building renovation, streamline preservation approval processes, and create partnerships with preservation organizations to maintain historic character."
        },
        {
          title: "Adaptive Reuse and Heritage Tourism",
          description: "Promote adaptive reuse of historic buildings for modern purposes, develop heritage tourism initiatives, and create interpretive programs that celebrate community history while generating economic activity."
        },
        {
          title: "Community Heritage Documentation",
          description: "Document and preserve community history through oral history projects, historical photography, cultural mapping, and community-led preservation initiatives that engage residents in protecting their heritage."
        }
      ],
      "Recreation Facility Inadequacy" => [
        {
          title: "Community Recreation Center Development",
          description: "Build or renovate community recreation centers offering fitness facilities, sports courts, meeting spaces, and programming for all ages, with particular attention to underserved neighborhoods and accessibility."
        },
        {
          title: "Parks and Trail System Expansion",
          description: "Develop connected network of parks, trails, and open spaces through land acquisition, trail development, park improvements, and partnerships that provide recreational opportunities throughout the community."
        },
        {
          title: "Youth Recreation and Sports Programs",
          description: "Expand youth programming including sports leagues, after-school programs, summer camps, and leadership development that provide safe, constructive activities and reduce juvenile crime and risky behaviors."
        }
      ],
      "Library Service Limitations" => [
        {
          title: "21st Century Library Services",
          description: "Modernize library services with updated technology, expanded digital collections, maker spaces, programming for all ages, and extended hours to serve as community learning and gathering centers."
        },
        {
          title: "Branch Library and Mobile Services",
          description: "Establish branch libraries or mobile library services to reach underserved areas, provide neighborhood access to library resources, and create partnerships with schools and community organizations."
        },
        {
          title: "Library as Community Hub",
          description: "Transform libraries into comprehensive community hubs offering social services, job training, computer access, meeting spaces, and cultural programming that serve diverse community needs beyond traditional library services."
        }
      ]
    }
    
    approaches_by_issue.each do |issue_title, approaches|
      issue = Issue.find_by(title: issue_title)
      unless issue
        puts "\n❌ Issue not found: #{issue_title}"
        next
      end
      
      approaches.each do |approach_attrs|
        approach = Approach.find_or_create_by(title: approach_attrs[:title], issue: issue) do |a|
          a.description = approach_attrs[:description]
        end
        
        if approach.persisted?
          print "."
        else
          puts "\n❌ Failed to create approach: #{approach_attrs[:title]}"
          puts "   Errors: #{approach.errors.full_messages.join(', ')}"
        end
      end
    end
    
    puts " #{Approach.count} approaches"
  end
end