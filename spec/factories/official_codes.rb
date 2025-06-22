FactoryBot.define do
  factory :official_code do
    association :policy
    code_number { "Municipal Code 15.2.3" }
    title { "Affordable Housing Development Standards" }
    full_text { "Section 15.2.3 - Affordable Housing Requirements\n\n(a) Applicability: This section applies to all new residential developments of ten (10) or more units within the city limits.\n\n(b) Affordable Housing Requirement: All qualifying developments shall provide affordable housing units equal to fifteen percent (15%) of the total residential units, or pay an in-lieu fee as specified in subsection (d).\n\n(c) Affordability Standards: Affordable units shall be made available to households earning no more than eighty percent (80%) of the area median income (AMI) for a period of not less than thirty (30) years.\n\n(d) In-Lieu Fee: Developers may satisfy the affordable housing requirement by paying an in-lieu fee of $50,000 per required affordable unit to the City Housing Trust Fund.\n\n(e) Incentives: Developments exceeding the minimum affordable housing requirement by five percent (5%) or more shall receive a density bonus of up to twenty percent (20%) above the base zoning allowance.\n\n(f) Administration: The Planning Department shall administer this program and maintain records of compliance." }
    summary { "Requires new developments of 10+ units to include 15% affordable housing or pay fees to housing trust fund. Provides density bonuses for exceeding requirements. Affordable units must serve households earning 80% or less of area median income for 30 years." }
    enforcement_mechanism { "Planning Department reviews all development applications for compliance. Building permits cannot be issued without proof of affordable housing provision or in-lieu fee payment. Annual compliance monitoring required for affordable units." }
    penalty_structure { "Violation: $1,000 per day until compliance achieved. False certification: $10,000 fine plus compliance costs. Repeat violations: Additional $5,000 penalty and potential permit suspension." }
    effective_date { 2.years.ago }
    status { "active" }
    trait :zoning_code do
      code_number { "Zoning Code 8.4.12" }
      title { "Complete Streets Design Standards" }
      full_text { "Section 8.4.12 - Complete Streets Requirements\n\n(a) Purpose: To ensure all street improvements accommodate pedestrians, cyclists, transit users, and motor vehicles through universal design.\n\n(b) Applicability: Applies to all new street construction, reconstruction projects over $100,000, and major street improvements.\n\n(c) Design Elements Required:\n  (1) Sidewalks minimum 6 feet wide, 8 feet in commercial areas\n  (2) Bicycle facilities appropriate to street classification\n  (3) Transit stops with accessibility features where applicable\n  (4) Street trees and landscaping per urban forestry standards\n  (5) Accessible pedestrian crossings at all intersections\n\n(d) Exceptions: City Engineer may grant exceptions where topography, right-of-way constraints, or safety concerns make compliance infeasible.\n\n(e) Coordination: All street projects must be coordinated with Transportation Master Plan and ADA transition plan." }
      summary { "Requires all new streets and major improvements to include sidewalks, bike facilities, transit accommodations, and accessible design. Exceptions allowed for physical constraints or safety issues." }
      enforcement_mechanism { "Public Works Department reviews all street improvement plans. No construction permits issued without complete streets compliance. Post-construction inspection required." }
      penalty_structure { "Non-compliance delays: $500 per day construction delay. Design deficiencies: Correction at contractor expense. Willful violations: $2,500 fine plus correction costs." }
    end
    trait :health_code do
      code_number { "Health Code 12.1.8" }
      title { "Food Safety and Inspection Standards" }
      full_text { "Section 12.1.8 - Food Establishment Requirements\n\n(a) Permit Required: No person shall operate a food establishment without a valid permit from the Health Department.\n\n(b) Inspection Schedule: Initial inspection before permit issuance, annual renewal inspections, and complaint-based inspections as needed.\n\n(c) Food Safety Requirements:\n  (1) Food handler certification for all employees\n  (2) Temperature monitoring and documentation\n  (3) Sanitation procedures per state guidelines\n  (4) Pest control measures\n  (5) Proper food storage and labeling\n\n(d) Violations Classification:\n  (1) Critical violations: Immediate health risk\n  (2) Major violations: Significant health risk\n  (3) Minor violations: Regulatory non-compliance\n\n(e) Enforcement: Critical violations require immediate correction. Permit suspension for repeated major violations." }
      summary { "Establishes food safety requirements for restaurants and food establishments. Requires permits, regular inspections, certified food handlers, and proper sanitation. Violations classified by health risk level." }
      enforcement_mechanism { "Health Department conducts announced and unannounced inspections. Violation notices with correction timelines issued. Follow-up inspections verify compliance." }
      penalty_structure { "Critical violations: Immediate closure until corrected. Major violations: $250 fine, permit suspension after 3 violations. Minor violations: $100 fine, correction within 30 days." }
    end
    trait :environmental_code do
      code_number { "Environmental Code 18.3.5" }
      title { "Air Quality and Emissions Standards" }
      full_text { "Section 18.3.5 - Industrial Emissions Limitations\n\n(a) Applicability: All industrial facilities with emissions sources must comply with federal, state, and local air quality standards.\n\n(b) Permit Requirements: Operating permit required for all major emission sources. Annual reporting of emissions data mandatory.\n\n(c) Emission Limits:\n  (1) Particulate matter: 0.1 grains per standard cubic foot\n  (2) Sulfur dioxide: 500 parts per million maximum\n  (3) Nitrogen oxides: 400 parts per million maximum\n  (4) Volatile organic compounds per EPA standards\n\n(d) Monitoring Requirements: Continuous emission monitoring for major sources. Quarterly stack testing for specified pollutants.\n\n(e) Reporting: Monthly emission reports to Environmental Department. Annual compliance certification required.\n\n(f) Best Available Technology: New sources must use best available control technology." }
      summary { "Sets emission limits for industrial facilities and requires permits, monitoring, and reporting. Establishes specific limits for major pollutants and mandates use of best available technology for new sources." }
      enforcement_mechanism { "Environmental Department reviews permits and monitors compliance. Quarterly inspections and stack testing verification. Real-time emission monitoring reviewed daily." }
      penalty_structure { "Excess emissions: $1,000 per day per violation. Reporting failures: $500 per missed report. Major violations: $10,000 fine plus correction costs. Permit revocation for willful violations." }
    end
    trait :business_code do
      code_number { "Business Code 5.2.7" }
      title { "Small Business Development Incentives" }
      full_text { "Section 5.2.7 - Local Business Support Program\n\n(a) Purpose: To encourage local business development and job creation through regulatory and financial incentives.\n\n(b) Eligible Businesses: Businesses with fewer than 50 employees, locally owned and operated, providing goods or services within the city.\n\n(c) Available Incentives:\n  (1) 50% reduction in business license fees for first year\n  (2) Expedited permitting for qualifying projects\n  (3) Free technical assistance and business counseling\n  (4) Access to revolving loan fund at below-market rates\n  (5) Preference in city procurement under $25,000\n\n(d) Application Process: Submit application with business plan, financial projections, and job creation estimates. Quarterly progress reports required.\n\n(e) Performance Standards: Must create minimum 2 full-time equivalent jobs within 18 months and maintain operations for minimum 3 years." }
      summary { "Provides incentives for small local businesses including fee reductions, expedited permits, technical assistance, loan access, and procurement preferences. Requires job creation and operational commitments." }
      enforcement_mechanism { "Economic Development Department administers program. Application review committee evaluates proposals. Quarterly monitoring of job creation and business operations." }
      penalty_structure { "Failure to meet job targets: Proportional incentive repayment. False information: Full incentive repayment plus $2,500 penalty. Early closure: Pro-rated incentive repayment." }
    end
    trait :housing_code do
      code_number { "Housing Code 14.5.2" }
      title { "Rental Property Safety and Habitability Standards" }
      full_text { "Section 14.5.2 - Minimum Housing Standards\n\n(a) Registration Required: All rental properties must be registered with the Housing Department and renewed annually.\n\n(b) Safety Requirements:\n  (1) Working smoke and carbon monoxide detectors in all units\n  (2) Adequate heating systems maintaining 68°F minimum\n  (3) Hot water availability 24 hours daily\n  (4) Secure locks on all exterior doors and windows\n  (5) Safe electrical systems meeting current codes\n\n(c) Habitability Standards:\n  (1) No water leaks or moisture problems\n  (2) Pest-free conditions\n  (3) Functional plumbing and fixtures\n  (4) Adequate natural light and ventilation\n  (5) Clean and sanitary conditions\n\n(d) Inspection Program: Biennial inspections for all registered properties. Complaint-based inspections within 48 hours.\n\n(e) Tenant Rights: Tenants may request inspections and withhold rent for uncorrected violations." }
      summary { "Establishes safety and habitability standards for rental properties. Requires registration, regular inspections, and specific safety features. Protects tenant rights to safe, habitable housing." }
      enforcement_mechanism { "Housing Department conducts scheduled and complaint-based inspections. Violation notices with correction deadlines issued. Follow-up inspections verify compliance." }
      penalty_structure { "Safety violations: $500 per day until corrected. Registration violations: $250 fine plus compliance. Habitability violations: $300 per violation. Repeat violations: Double penalties." }
    end
    trait :superseded do
      status { "superseded" }
      code_number { "Former Code 10.1.5" }
      title { "Superseded Parking Requirements" }
      full_text { "[This code has been superseded by Zoning Code 8.2.14 - Flexible Parking Standards]\n\nFormer Section 10.1.5 - Minimum Parking Requirements\n\n(a) Required Spaces: Residential developments shall provide minimum parking as follows:\n  (1) Single-family: 2 spaces per unit\n  (2) Multi-family: 1.5 spaces per unit\n  (3) Senior housing: 0.5 spaces per unit\n\n(b) Commercial Requirements: Retail and office uses shall provide 1 space per 300 square feet of floor area.\n\n[NOTE: This code was repealed and replaced to encourage transit-oriented development and reduce housing costs.]" }
      summary { "Former parking requirements that mandated minimum parking spaces for all developments. Superseded by flexible parking standards that allow reductions near transit and in dense areas." }
      enforcement_mechanism { "No longer enforced. Replaced by Zoning Code 8.2.14 which allows parking reductions based on transit access, shared parking agreements, and demand management programs." }
      penalty_structure { "No longer applicable. Violations under former code were $100 per missing space plus compliance costs." }
      effective_date { 5.years.ago }
    end
    trait :repealed do
      status { "repealed" }
      code_number { "Repealed Code 7.3.9" }
      title { "Repealed Single-Use Plastic Bag Ban" }
      full_text { "[This code has been repealed and replaced by Environmental Code 18.7.2 - Comprehensive Waste Reduction]\n\nFormer Section 7.3.9 - Plastic Bag Prohibition\n\n(a) Prohibited Items: Retail establishments shall not provide single-use plastic bags to customers.\n\n(b) Allowed Alternatives: Paper bags, reusable bags, and bags for produce or bulk items.\n\n[NOTE: This narrow ban was replaced with comprehensive waste reduction ordinance covering multiple single-use items.]" }
      summary { "Former law banning single-use plastic bags at retail stores. Repealed and replaced with broader waste reduction ordinance covering additional single-use items and packaging." }
      enforcement_mechanism { "No longer enforced. Environmental Department now enforces broader waste reduction requirements under Environmental Code 18.7.2." }
      penalty_structure { "No longer applicable. Former penalties were $250 per violation with increasing fines for repeat offenses." }
      effective_date { 3.years.ago }
    end
    factory :zoning_code_example, traits: [:zoning_code]
    factory :health_code_example, traits: [:health_code]
    factory :environmental_code_example, traits: [:environmental_code]
    factory :business_code_example, traits: [:business_code]
    factory :housing_code_example, traits: [:housing_code]
    factory :superseded_code_example, traits: [:superseded]
    factory :repealed_code_example, traits: [:repealed]
  end
end

