class OfficialCodeSeeder
  def self.seed
    # Create official codes that implement policies with specific legal text and enforcement
    code_configurations = [
      # Housing Policy Implementation
      {
        policy_title: "Affordable Housing Inclusion Requirements",
        code_number: "Municipal Code 15.2.3",
        title: "Affordable Housing Development Standards",
        full_text: "Section 15.2.3 - Affordable Housing Requirements\n\n(a) Applicability: This section applies to all new residential developments of ten (10) or more units within the city limits.\n\n(b) Affordable Housing Requirement: All qualifying developments shall provide affordable housing units equal to fifteen percent (15%) of the total residential units, or pay an in-lieu fee as specified in subsection (d).\n\n(c) Affordability Standards: Affordable units shall be made available to households earning no more than eighty percent (80%) of the area median income (AMI) for a period of not less than thirty (30) years.\n\n(d) In-Lieu Fee: Developers may satisfy the affordable housing requirement by paying an in-lieu fee of $50,000 per required affordable unit to the City Housing Trust Fund.\n\n(e) Incentives: Developments exceeding the minimum affordable housing requirement by five percent (5%) or more shall receive a density bonus of up to twenty percent (20%) above the base zoning allowance.\n\n(f) Administration: The Planning Department shall administer this program and maintain records of compliance.",
        summary: "Requires new developments of 10+ units to include 15% affordable housing or pay fees to housing trust fund. Provides density bonuses for exceeding requirements. Affordable units must serve households earning 80% or less of area median income for 30 years.",
        enforcement_mechanism: "Planning Department reviews all development applications for compliance. Building permits cannot be issued without proof of affordable housing provision or in-lieu fee payment. Annual compliance monitoring required for affordable units.",
        penalty_structure: "Violation: $1,000 per day until compliance achieved. False certification: $10,000 fine plus compliance costs. Repeat violations: Additional $5,000 penalty and potential permit suspension.",
        status: "active"
      },
      
      # Transportation Policy Implementation
      {
        policy_title: "Complete Streets Ordinance",
        code_number: "Public Works Code 8.4.12",
        title: "Complete Streets Design Standards",
        full_text: "Section 8.4.12 - Complete Streets Requirements\n\n(a) Purpose: To ensure all street improvements accommodate pedestrians, cyclists, transit users, and motor vehicles through universal design.\n\n(b) Applicability: Applies to all new street construction, reconstruction projects over $100,000, and major street improvements.\n\n(c) Design Elements Required:\n  (1) Sidewalks minimum 6 feet wide, 8 feet in commercial areas\n  (2) Bicycle facilities appropriate to street classification\n  (3) Transit stops with accessibility features where applicable\n  (4) Street trees and landscaping per urban forestry standards\n  (5) Accessible pedestrian crossings at all intersections\n\n(d) Exceptions: City Engineer may grant exceptions where topography, right-of-way constraints, or safety concerns make compliance infeasible.\n\n(e) Coordination: All street projects must be coordinated with Transportation Master Plan and ADA transition plan.",
        summary: "Requires all new streets and major improvements to include sidewalks, bike facilities, transit accommodations, and accessible design. Exceptions allowed for physical constraints or safety issues.",
        enforcement_mechanism: "Public Works Department reviews all street improvement plans. No construction permits issued without complete streets compliance. Post-construction inspection required.",
        penalty_structure: "Non-compliance delays: $500 per day construction delay. Design deficiencies: Correction at contractor expense. Willful violations: $2,500 fine plus correction costs.",
        status: "active"
      },
      
      # Environmental Policy Implementation  
      {
        policy_title: "Climate Action and Resilience Plan",
        code_number: "Environmental Code 18.3.5",
        title: "Greenhouse Gas Reduction Requirements",
        full_text: "Section 18.3.5 - Municipal Emissions Standards\n\n(a) Targets: The city shall reduce greenhouse gas emissions by 50% below 2005 levels by 2030 and achieve carbon neutrality by 2045.\n\n(b) Building Standards: All new construction over 5,000 square feet must meet energy efficiency standards exceeding state code by 15%.\n\n(c) Renewable Energy: New residential developments of 10+ units must include solar energy systems sized to offset 50% of estimated electricity use.\n\n(d) Transportation: City fleet must transition to electric or alternative fuel vehicles, with 75% conversion by 2028.\n\n(e) Monitoring: Annual greenhouse gas inventory required with public reporting.\n\n(f) Green Building: All city buildings must achieve LEED Gold certification or equivalent.\n\n(g) Tree Protection: Net tree canopy coverage must increase by 2% annually through development requirements and city planting programs.",
        summary: "Sets specific emissions reduction targets and requirements for buildings, renewable energy, transportation, and tree canopy. Establishes monitoring and reporting requirements for progress tracking.",
        enforcement_mechanism: "Environmental Department tracks progress through annual inventories. Building Department enforces construction standards. Fleet Manager coordinates vehicle transitions.",
        penalty_structure: "Building code violations: $500 per day until compliance. False reporting: $2,500 fine. Non-compliance with renewable energy: $10,000 per project plus installation requirement.",
        status: "active"
      },
      
      # Economic Development Policy Implementation
      {
        policy_title: "Local Business Development Incentives", 
        code_number: "Business Code 5.2.7",
        title: "Small Business Development Incentives",
        full_text: "Section 5.2.7 - Local Business Support Program\n\n(a) Purpose: To encourage local business development and job creation through regulatory and financial incentives.\n\n(b) Eligible Businesses: Businesses with fewer than 50 employees, locally owned and operated, providing goods or services within the city.\n\n(c) Available Incentives:\n  (1) 50% reduction in business license fees for first year\n  (2) Expedited permitting for qualifying projects\n  (3) Free technical assistance and business counseling\n  (4) Access to revolving loan fund at below-market rates\n  (5) Preference in city procurement under $25,000\n\n(d) Application Process: Submit application with business plan, financial projections, and job creation estimates. Quarterly progress reports required.\n\n(e) Performance Standards: Must create minimum 2 full-time equivalent jobs within 18 months and maintain operations for minimum 3 years.",
        summary: "Provides incentives for small local businesses including fee reductions, expedited permits, technical assistance, loan access, and procurement preferences. Requires job creation and operational commitments.",
        enforcement_mechanism: "Economic Development Department administers program. Application review committee evaluates proposals. Quarterly monitoring of job creation and business operations.",
        penalty_structure: "Failure to meet job targets: Proportional incentive repayment. False information: Full incentive repayment plus $2,500 penalty. Early closure: Pro-rated incentive repayment.",
        status: "active"
      },
      
      # Public Safety Policy Implementation
      {
        policy_title: "Community Safety and Accountability Act",
        code_number: "Police Code 9.1.15", 
        title: "Community Policing and Accountability Standards",
        full_text: "Section 9.1.15 - Community Policing Requirements\n\n(a) Community Engagement: Each patrol district must hold monthly community meetings with residents and business owners.\n\n(b) Bias Training: All officers must complete 40 hours of bias awareness and cultural competency training annually.\n\n(c) De-escalation: Officers must attempt de-escalation techniques before using force, except in immediate threat situations.\n\n(d) Civilian Oversight: Independent oversight board with subpoena power reviews all use of force incidents and civilian complaints.\n\n(e) Data Collection: Department must collect and publicly report data on traffic stops, searches, arrests, and use of force by officer demographics and incident characteristics.\n\n(f) Body Cameras: All officers must wear activated body cameras during public interactions with automatic activation triggers.\n\n(g) Crisis Response: Mental health professionals must respond to mental health crisis calls with police backup.",
        summary: "Establishes community policing requirements, oversight mechanisms, training standards, and data collection. Mandates body cameras and specialized crisis response protocols.",
        enforcement_mechanism: "Police Chief ensures compliance with training and equipment requirements. Oversight Board investigates complaints. City Manager reviews performance metrics quarterly.",
        penalty_structure: "Training non-compliance: Officer suspension until completion. Policy violations: Progressive discipline per collective bargaining agreement. Equipment violations: $100 fine per incident.",
        status: "active"
      },
      
      # Healthcare Policy Implementation
      {
        policy_title: "Universal Healthcare Access Initiative",
        code_number: "Health Code 12.4.8",
        title: "Community Health Center Standards",
        full_text: "Section 12.4.8 - Health Center Operations\n\n(a) Services Required: Centers must provide primary care, preventive services, mental health counseling, and prescription assistance.\n\n(b) Sliding Fee Scale: Services provided on sliding scale based on federal poverty guidelines, with free care for households under 100% of poverty level.\n\n(c) Staffing Requirements: Minimum staffing ratios of 1 primary care provider per 1,200 patients and 1 mental health provider per 800 patients.\n\n(d) Access Standards: Appointment available within 48 hours for urgent care, 2 weeks for routine care, and same-day for mental health crisis.\n\n(e) Language Services: Interpretation services must be available in Spanish and other languages representing 5% or more of service area population.\n\n(f) Quality Measures: Centers must meet or exceed state quality benchmarks for preventive care, chronic disease management, and patient satisfaction.",
        summary: "Establishes service requirements, sliding fee scales, staffing ratios, and access standards for community health centers. Ensures language accessibility and quality benchmarks.",
        enforcement_mechanism: "Health Department conducts annual site visits and reviews quality metrics. Patient complaints investigated within 30 days. Contract compliance monitored quarterly.",
        penalty_structure: "Staffing violations: $1,000 per day below minimum. Access standard failures: $500 per documented delay. Quality benchmark failures: Performance improvement plan required.",
        status: "active"
      },
      
      # Education Policy Implementation
      {
        policy_title: "Universal Pre-K and Early Learning Program",
        code_number: "Education Code 6.3.2",
        title: "Early Childhood Education Standards",
        full_text: "Section 6.3.2 - Pre-Kindergarten Program Requirements\n\n(a) Universal Access: Free pre-kindergarten available to all district 4-year-olds regardless of family income.\n\n(b) Teacher Qualifications: All pre-K teachers must hold early childhood education certification and bachelor's degree minimum.\n\n(c) Class Size: Maximum 18 students per class with 1 teacher and 1 aide.\n\n(d) Curriculum Standards: Evidence-based curriculum emphasizing social-emotional learning, literacy, math concepts, and school readiness skills.\n\n(e) Family Engagement: Monthly family education workshops and home visits for interested families.\n\n(f) Assessment: Developmental screenings at enrollment and progress monitoring using research-based tools.\n\n(g) Transition Support: Coordination with elementary schools to ensure smooth kindergarten transition.",
        summary: "Establishes universal pre-K program with qualified teachers, small class sizes, evidence-based curriculum, and family engagement components. Includes assessment and transition support.",
        enforcement_mechanism: "Education Department monitors teacher qualifications and class sizes. Curriculum specialists conduct quarterly classroom observations. Family engagement tracked through participation data.",
        penalty_structure: "Qualification violations: Teacher reassignment until certification obtained. Class size violations: $200 per day per student over limit. Curriculum non-compliance: Professional development required.",
        status: "active"
      },
      
      # Water Quality Policy Implementation
      {
        policy_title: "Water Quality Protection Standards",
        code_number: "Water Code 20.2.6",
        title: "Watershed Protection Requirements",
        full_text: "Section 20.2.6 - Water Quality Standards\n\n(a) Discharge Permits: All point source discharges to watershed require permits with specific pollutant limits.\n\n(b) Stormwater Management: New development must include stormwater best management practices to prevent runoff pollution.\n\n(c) Buffer Zones: 100-foot vegetated buffer required along all streams and water bodies within the watershed.\n\n(d) Water Quality Monitoring: Monthly testing at 15 locations throughout watershed for bacteria, nutrients, and chemical contaminants.\n\n(e) Emergency Response: Pollution spill response plan with 2-hour notification requirement and containment procedures.\n\n(f) Public Reporting: Quarterly water quality reports published online with explanation of results and any violations.\n\n(g) Source Protection: Wellhead protection zones with restricted activities within 1,000 feet of public water supply wells.",
        summary: "Establishes comprehensive water quality protection through discharge permits, stormwater management, buffer zones, monitoring, and emergency response. Includes public reporting requirements.",
        enforcement_mechanism: "Water District staff conduct monthly monitoring and annual facility inspections. Violations reported to state environmental agency. Emergency response team available 24/7.",
        penalty_structure: "Discharge violations: $5,000 per day per violation. Buffer zone violations: $1,000 fine plus restoration costs. Monitoring failures: $500 per missed sample.",
        status: "active"
      },
      
      # Superseded Code Example
      {
        policy_title: "Minimum Parking Requirements (Repealed)",
        code_number: "Former Zoning Code 10.1.5",
        title: "Superseded Minimum Parking Requirements",
        full_text: "[This code has been superseded by Zoning Code 8.2.14 - Flexible Parking Standards]\n\nFormer Section 10.1.5 - Minimum Parking Requirements\n\n(a) Required Spaces: Residential developments shall provide minimum parking as follows:\n  (1) Single-family: 2 spaces per unit\n  (2) Multi-family: 1.5 spaces per unit\n  (3) Senior housing: 0.5 spaces per unit\n\n(b) Commercial Requirements: Retail and office uses shall provide 1 space per 300 square feet of floor area.\n\n(c) Variance Process: Parking reduction requests require special permit with findings of adequate alternative transportation.\n\n[NOTE: This code was repealed and replaced to encourage transit-oriented development and reduce housing costs.]",
        summary: "Former parking requirements that mandated minimum parking spaces for all developments. Superseded by flexible parking standards that allow reductions near transit and in dense areas.",
        enforcement_mechanism: "No longer enforced. Replaced by Zoning Code 8.2.14 which allows parking reductions based on transit access, shared parking agreements, and demand management programs.",
        penalty_structure: "No longer applicable. Violations under former code were $100 per missing space plus compliance costs.",
        status: "superseded"
      }
    ]
    
    code_configurations.each do |config|
      # Find policy by title
      policy = Policy.find_by(title: config[:policy_title])
      unless policy
        puts "\n❌ Policy not found: #{config[:policy_title]}"
        next
      end
      
      # Create the official code
      official_code = OfficialCode.find_or_create_by(
        code_number: config[:code_number],
        policy: policy
      ) do |oc|
        oc.title = config[:title]
        oc.full_text = config[:full_text]
        oc.summary = config[:summary]
        oc.enforcement_mechanism = config[:enforcement_mechanism]
        oc.penalty_structure = config[:penalty_structure]
        oc.effective_date = policy.enacted_date || 2.years.ago
        oc.status = config[:status]
      end
      
      if official_code.persisted?
        print "."
      else
        puts "\n❌ Failed to create official code: #{config[:code_number]}"
        puts "   Errors: #{official_code.errors.full_messages.join(', ')}"
      end
    end
    
    puts " #{OfficialCode.count} official codes"
  end
end