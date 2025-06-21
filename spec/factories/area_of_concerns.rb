FactoryBot.define do
  factory :area_of_concern do
    name { "Public Safety" }
    description { "Policies and programs related to law enforcement, emergency services, crime prevention, and community safety initiatives that protect residents and maintain public order." }
    policy_domain { "Safety & Security" }
    regulatory_scope { "Municipal, County, State" }

    trait :education do
      name { "Education Policy" }
      description { "Educational standards, funding, curriculum development, school administration, and educational equity programs that ensure quality learning opportunities for all students." }
      policy_domain { "Human Services" }
      regulatory_scope { "Local School District, State, Federal" }
    end

    trait :transportation do
      name { "Transportation Infrastructure" }
      description { "Road maintenance, public transit systems, traffic management, pedestrian safety, and transportation planning that ensures efficient movement of people and goods." }
      policy_domain { "Infrastructure" }
      regulatory_scope { "Municipal, County, Regional, State" }
    end

    trait :environment do
      name { "Environmental Protection" }
      description { "Environmental regulations, conservation programs, pollution control, climate action, and natural resource management to protect ecosystem health and sustainability." }
      policy_domain { "Environment" }
      regulatory_scope { "All Levels" }
    end

    trait :economic_development do
      name { "Economic Development" }
      description { "Business incentives, zoning regulations, economic growth strategies, workforce development, and small business support to foster local economic prosperity." }
      policy_domain { "Economic" }
      regulatory_scope { "Municipal, County, State, Federal" }
    end

    trait :healthcare do
      name { "Healthcare Services" }
      description { "Public health programs, healthcare access, health insurance policies, disease prevention, and health emergency preparedness to ensure community wellness." }
      policy_domain { "Human Services" }
      regulatory_scope { "County, State, Federal" }
    end

    trait :housing do
      name { "Housing & Urban Development" }
      description { "Affordable housing programs, zoning laws, building codes, homelessness services, and community development to ensure adequate housing for all residents." }
      policy_domain { "Infrastructure" }
      regulatory_scope { "Municipal, County, State, Federal" }
    end

    trait :social_services do
      name { "Social Services" }
      description { "Welfare programs, disability services, senior services, child protective services, and community support programs that provide safety nets for vulnerable populations." }
      policy_domain { "Human Services" }
      regulatory_scope { "County, State, Federal" }
    end

    trait :parks_recreation do
      name { "Parks & Recreation" }
      description { "Park maintenance, recreational programs, sports facilities, cultural events, and community centers that enhance quality of life and community engagement." }
      policy_domain { "Quality of Life" }
      regulatory_scope { "Municipal, County, Special District" }
    end

    trait :budget_finance do
      name { "Budget & Finance" }
      description { "Government budgeting, taxation policies, debt management, financial transparency, and fiscal responsibility that ensures sound financial governance." }
      policy_domain { "Governance" }
      regulatory_scope { "All Levels" }
    end

    trait :technology do
      name { "Technology & Innovation" }
      description { "Digital infrastructure, cybersecurity, government technology services, broadband access, and digital equity initiatives that modernize public services." }
      policy_domain { "Infrastructure" }
      regulatory_scope { "Municipal, County, State, Federal" }
    end

    trait :agriculture do
      name { "Agriculture & Food Security" }
      description { "Agricultural policies, food safety regulations, farming support programs, and local food systems that ensure sustainable food production and distribution." }
      policy_domain { "Economic" }
      regulatory_scope { "County, State, Federal" }
    end

    trait :energy do
      name { "Energy Policy" }
      description { "Renewable energy programs, utility regulations, energy efficiency standards, and energy independence initiatives that promote sustainable energy systems." }
      policy_domain { "Environment" }
      regulatory_scope { "Municipal, County, State, Federal" }
    end

    trait :immigration do
      name { "Immigration & Integration" }
      description { "Immigration services, refugee resettlement, citizenship programs, and community integration support that help newcomers become contributing community members." }
      policy_domain { "Human Services" }
      regulatory_scope { "Municipal, County, State, Federal" }
    end

    trait :arts_culture do
      name { "Arts & Culture" }
      description { "Cultural programs, arts funding, historic preservation, museums, libraries, and community cultural events that enrich community life and preserve heritage." }
      policy_domain { "Quality of Life" }
      regulatory_scope { "Municipal, County, State" }
    end

    # Policy domain-specific traits
    trait :safety_security_domain do
      policy_domain { "Safety & Security" }
    end

    trait :human_services_domain do
      policy_domain { "Human Services" }
    end

    trait :infrastructure_domain do
      policy_domain { "Infrastructure" }
    end

    trait :environment_domain do
      policy_domain { "Environment" }
    end

    trait :economic_domain do
      policy_domain { "Economic" }
    end

    trait :quality_of_life_domain do
      policy_domain { "Quality of Life" }
    end

    trait :governance_domain do
      policy_domain { "Governance" }
    end

    # Regulatory scope traits
    trait :local_scope do
      regulatory_scope { "Municipal, County" }
    end

    trait :regional_scope do
      regulatory_scope { "Regional, State" }
    end

    trait :federal_scope do
      regulatory_scope { "Federal" }
    end

    trait :all_levels_scope do
      regulatory_scope { "All Levels" }
    end

    # Named factories for common scenarios
    factory :education_area_of_concern, traits: [:education]
    factory :transportation_area_of_concern, traits: [:transportation]
    factory :environment_area_of_concern, traits: [:environment]
    factory :economic_development_area_of_concern, traits: [:economic_development]
    factory :healthcare_area_of_concern, traits: [:healthcare]
    factory :housing_area_of_concern, traits: [:housing]
    factory :social_services_area_of_concern, traits: [:social_services]
    factory :parks_recreation_area_of_concern, traits: [:parks_recreation]
    factory :budget_finance_area_of_concern, traits: [:budget_finance]
    factory :technology_area_of_concern, traits: [:technology]
    factory :agriculture_area_of_concern, traits: [:agriculture]
    factory :energy_area_of_concern, traits: [:energy]
    factory :immigration_area_of_concern, traits: [:immigration]
    factory :arts_culture_area_of_concern, traits: [:arts_culture]
  end
end
