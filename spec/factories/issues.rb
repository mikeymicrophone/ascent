FactoryBot.define do
  factory :issue do
    title { "High Crime Rates" }
    description { "Rising crime rates in downtown areas are creating safety concerns for residents and businesses, requiring comprehensive intervention strategies." }
    association :topic
    trait :affordable_housing do
      title { "Affordable Housing Shortage" }
      description { "Lack of affordable housing options is displacing long-term residents and creating barriers to homeownership for working families." }
      association :topic, factory: :housing_topic
    end
    trait :school_funding do
      title { "Inadequate School Funding" }
      description { "Insufficient funding for public schools is resulting in larger class sizes, outdated materials, and limited extracurricular programs." }
      association :topic, factory: :education_topic
    end
    trait :traffic_congestion do
      title { "Traffic Congestion" }
      description { "Heavy traffic congestion during peak hours is increasing commute times, air pollution, and economic costs for residents and businesses." }
      association :topic, factory: :transportation_topic
    end
    trait :healthcare_access do
      title { "Limited Healthcare Access" }
      description { "Residents in rural and low-income areas face barriers to accessing quality healthcare services, including specialists and emergency care." }
      association :topic, factory: :healthcare_topic
    end
    trait :unemployment do
      title { "High Unemployment Rates" }
      description { "Persistent unemployment in certain demographics and geographic areas is limiting economic mobility and community development." }
      association :topic, factory: :economic_development_topic
    end
    trait :environmental_pollution do
      title { "Air and Water Pollution" }
      description { "Industrial activities and urban runoff are contaminating local air and water sources, threatening public health and ecosystem integrity." }
      association :topic, factory: :environment_topic
    end
    trait :government_corruption do
      title { "Lack of Government Transparency" }
      description { "Limited public access to government decision-making processes and budget information is eroding public trust and accountability." }
      association :topic, factory: :government_accountability_topic
    end
    trait :senior_services do
      title { "Inadequate Senior Services" }
      description { "Growing senior population lacks access to comprehensive healthcare, transportation, and social services needed for aging in place." }
      association :topic, factory: :social_services_topic
    end
    trait :infrastructure_decay do
      title { "Aging Infrastructure" }
      description { "Deteriorating roads, bridges, and utility systems are creating safety hazards and increasing maintenance costs for the community." }
      association :topic, factory: :infrastructure_topic
    end
    trait :cultural_preservation do
      title { "Loss of Cultural Heritage" }
      description { "Historic buildings and cultural traditions are disappearing due to development pressures and lack of preservation funding." }
      association :topic, factory: :arts_culture_topic
    end
    factory :affordable_housing_issue, traits: [:affordable_housing]
    factory :school_funding_issue, traits: [:school_funding]
    factory :traffic_congestion_issue, traits: [:traffic_congestion]
    factory :healthcare_access_issue, traits: [:healthcare_access]
    factory :unemployment_issue, traits: [:unemployment]
    factory :environmental_pollution_issue, traits: [:environmental_pollution]
    factory :government_transparency_issue, traits: [:government_corruption]
    factory :senior_services_issue, traits: [:senior_services]
    factory :infrastructure_decay_issue, traits: [:infrastructure_decay]
    factory :cultural_preservation_issue, traits: [:cultural_preservation]
  end
end

