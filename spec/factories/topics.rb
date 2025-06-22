FactoryBot.define do
  factory :topic do
    title { "Public Safety" }
    description { "Community safety, crime prevention, and emergency response policies that protect residents and maintain public order in our neighborhoods." }
    trait :education do
      title { "Education Policy" }
      description { "Educational standards, funding, curriculum development, and school administration policies that ensure quality learning opportunities for all students." }
    end
    trait :healthcare do
      title { "Healthcare Access" }
      description { "Healthcare services, insurance policies, public health programs, and medical accessibility initiatives that promote community wellness." }
    end
    trait :transportation do
      title { "Transportation Infrastructure" }
      description { "Road maintenance, public transit systems, traffic management, and transportation planning that ensures efficient movement of people and goods." }
    end
    trait :environment do
      title { "Environmental Protection" }
      description { "Environmental regulations, conservation programs, pollution control, and climate action policies that protect ecosystem health and sustainability." }
    end
    trait :economic_development do
      title { "Economic Development" }
      description { "Business growth strategies, workforce development, entrepreneurship support, and economic policies that foster local prosperity and job creation." }
    end
    trait :housing do
      title { "Housing & Development" }
      description { "Housing policies, zoning regulations, affordable housing programs, and urban development initiatives that ensure adequate shelter for all residents." }
    end
    trait :government_accountability do
      title { "Government Accountability" }
      description { "Transparency in government operations, ethical standards, budget oversight, and citizen engagement policies that ensure responsive democratic governance." }
    end
    trait :social_services do
      title { "Social Services" }
      description { "Welfare programs, disability services, senior care, and community support systems that provide safety nets for vulnerable populations." }
    end
    trait :infrastructure do
      title { "Infrastructure Development" }
      description { "Public works, utilities, technology infrastructure, and maintenance programs that support community functionality and growth." }
    end
    trait :arts_culture do
      title { "Arts & Culture" }
      description { "Cultural programs, arts funding, historic preservation, and community cultural events that enrich community life and preserve heritage." }
    end
    factory :education_topic, traits: [:education]
    factory :healthcare_topic, traits: [:healthcare]
    factory :transportation_topic, traits: [:transportation]
    factory :environment_topic, traits: [:environment]
    factory :economic_development_topic, traits: [:economic_development]
    factory :housing_topic, traits: [:housing]
    factory :government_accountability_topic, traits: [:government_accountability]
    factory :social_services_topic, traits: [:social_services]
    factory :infrastructure_topic, traits: [:infrastructure]
    factory :arts_culture_topic, traits: [:arts_culture]
  end
end

