FactoryBot.define do
  factory :approach do
    title { "Community Policing Initiative" }
    description { "Implement community-based policing strategies that focus on building relationships between law enforcement and residents, including neighborhood watch programs and regular community meetings." }
    association :issue
    trait :affordable_housing_program do
      title { "Affordable Housing Development Program" }
      description { "Create public-private partnerships to develop affordable housing units, including inclusionary zoning requirements and housing trust fund financing." }
      association :issue, factory: :affordable_housing_issue
    end
    trait :school_improvement_initiative do
      title { "School Improvement Initiative" }
      description { "Increase per-pupil funding through targeted tax measures, modernize school facilities, and recruit high-quality teachers with competitive compensation packages." }
      association :issue, factory: :school_funding_issue
    end
    trait :transit_expansion do
      title { "Public Transit Expansion" }
      description { "Expand bus routes and frequency, implement bus rapid transit systems, and create dedicated bike lanes to reduce car dependency and traffic congestion." }
      association :issue, factory: :traffic_congestion_issue
    end
    trait :mobile_health_clinics do
      title { "Mobile Health Clinic Program" }
      description { "Deploy mobile health clinics to underserved areas, partner with telehealth providers, and establish community health centers in rural locations." }
      association :issue, factory: :healthcare_access_issue
    end
    trait :job_training_program do
      title { "Job Training and Placement Program" }
      description { "Partner with local employers to provide skills training, apprenticeships, and job placement services focused on high-demand industries." }
      association :issue, factory: :unemployment_issue
    end
    trait :environmental_regulations do
      title { "Enhanced Environmental Regulations" }
      description { "Implement stricter emissions standards, require environmental impact assessments, and establish green infrastructure requirements for new developments." }
      association :issue, factory: :environmental_pollution_issue
    end
    trait :transparency_platform do
      title { "Government Transparency Platform" }
      description { "Create online portal for budget information, meeting minutes, and public records, plus establish regular town halls and citizen advisory committees." }
      association :issue, factory: :government_transparency_issue
    end
    trait :senior_support_services do
      title { "Comprehensive Senior Support Services" }
      description { "Establish senior centers, provide transportation services, expand meal programs, and create aging-in-place support services." }
      association :issue, factory: :senior_services_issue
    end
    trait :infrastructure_investment do
      title { "Infrastructure Investment Program" }
      description { "Implement systematic infrastructure assessment, prioritize critical repairs, and establish dedicated funding sources for ongoing maintenance and upgrades." }
      association :issue, factory: :infrastructure_decay_issue
    end
    trait :cultural_preservation_program do
      title { "Cultural Heritage Preservation Program" }
      description { "Establish historic preservation ordinances, create cultural arts funding, and develop community cultural centers to preserve and celebrate local heritage." }
      association :issue, factory: :cultural_preservation_issue
    end
    factory :affordable_housing_approach, traits: [:affordable_housing_program]
    factory :school_improvement_approach, traits: [:school_improvement_initiative]
    factory :transit_expansion_approach, traits: [:transit_expansion]
    factory :mobile_health_approach, traits: [:mobile_health_clinics]
    factory :job_training_approach, traits: [:job_training_program]
    factory :environmental_regulations_approach, traits: [:environmental_regulations]
    factory :transparency_platform_approach, traits: [:transparency_platform]
    factory :senior_support_approach, traits: [:senior_support_services]
    factory :infrastructure_investment_approach, traits: [:infrastructure_investment]
    factory :cultural_preservation_approach, traits: [:cultural_preservation_program]
  end
end

