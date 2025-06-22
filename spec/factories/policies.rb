FactoryBot.define do
  factory :policy do
    association :governing_body
    association :area_of_concern
    association :approach
    title { "Affordable Housing Development Standards" }
    description { "Comprehensive policy establishing requirements for affordable housing inclusion in new residential developments, density bonuses for developers, and streamlined permitting processes to address the housing shortage." }
    status { "active" }
    enacted_date { 2.years.ago }
    expiration_date { nil }
    trait :proposed do
      status { "proposed" }
      enacted_date { nil }
      title { "Proposed Climate Action Plan" }
      description { "Draft policy framework for achieving carbon neutrality through renewable energy incentives, green building standards, and transportation electrification initiatives." }
    end
    trait :under_review do
      status { "under_review" }
      enacted_date { nil }
      title { "Small Business Support Program Review" }
      description { "Comprehensive review of existing small business assistance programs to improve effectiveness, reduce administrative burden, and expand access to capital and technical assistance." }
    end
    trait :repealed do
      status { "repealed" }
      enacted_date { 10.years.ago }
      expiration_date { 1.year.ago }
      title { "Repealed Parking Minimum Requirements" }
      description { "Former policy requiring minimum parking spaces for all developments, repealed to encourage transit-oriented development and reduce housing costs." }
    end
    trait :education_policy do
      association :area_of_concern, factory: :education_area_of_concern
      association :approach, factory: :school_improvement_approach
      title { "School Funding Equity Initiative" }
      description { "Policy ensuring equitable per-pupil funding across all schools, with additional resources for high-need populations and performance accountability measures." }
      status { "active" }
      enacted_date { 3.years.ago }
    end
    trait :healthcare_policy do
      association :area_of_concern, factory: :healthcare_area_of_concern
      association :approach, factory: :mobile_health_approach
      title { "Rural Healthcare Access Program" }
      description { "Policy establishing mobile health clinic services, telemedicine infrastructure, and provider incentives to ensure healthcare access in underserved rural areas." }
      status { "active" }
      enacted_date { 18.months.ago }
    end
    trait :transportation_policy do
      association :area_of_concern, factory: :transportation_area_of_concern
      association :approach, factory: :transit_expansion_approach
      title { "Complete Streets Implementation" }
      description { "Policy requiring all new street construction and major renovations to accommodate pedestrians, cyclists, transit users, and vehicles through universal design principles." }
      status { "active" }
      enacted_date { 4.years.ago }
    end
    trait :environmental_policy do
      association :area_of_concern, factory: :environment_area_of_concern
      association :approach, factory: :environmental_regulations_approach
      title { "Environmental Protection Standards" }
      description { "Enhanced environmental regulations requiring impact assessments, emission monitoring, and pollution prevention measures for industrial and development activities." }
      status { "active" }
      enacted_date { 2.years.ago }
    end
    trait :housing_policy do
      association :area_of_concern, factory: :housing_area_of_concern
      association :approach, factory: :affordable_housing_approach
      title { "Inclusionary Housing Ordinance" }
      description { "Policy requiring new residential developments to include affordable units or contribute to housing trust fund, with incentives for exceeding requirements." }
      status { "active" }
      enacted_date { 3.years.ago }
    end
    trait :economic_policy do
      association :area_of_concern, factory: :economic_development_area_of_concern
      association :approach, factory: :job_training_approach
      title { "Workforce Development Partnership" }
      description { "Policy establishing partnerships between government, employers, and educational institutions to provide job training, apprenticeships, and career pathways." }
      status { "active" }
      enacted_date { 2.years.ago }
    end
    trait :temporary_policy do
      expiration_date { 1.year.from_now }
      title { "Emergency Housing Assistance Program" }
      description { "Temporary policy providing rental assistance and eviction prevention during economic hardship, with automatic renewal based on need assessment." }
      status { "active" }
      enacted_date { 6.months.ago }
    end
    trait :federal_policy do
      association :governing_body, factory: :federal_congress
      title { "National Infrastructure Investment Act" }
      description { "Federal policy providing funding for state and local infrastructure projects including roads, bridges, broadband, and green energy systems." }
      status { "active" }
      enacted_date { 1.year.ago }
    end
    trait :state_policy do
      association :governing_body, factory: :state_legislature_body
      title { "State Education Funding Formula" }
      description { "State policy establishing per-pupil funding formulas, equity adjustments for high-need districts, and accountability measures for academic performance." }
      status { "active" }
      enacted_date { 5.years.ago }
    end
    trait :local_policy do
      association :governing_body, factory: :city_council
      title { "Local Business Development Incentives" }
      description { "Municipal policy providing tax incentives, fee reductions, and technical assistance to support local business growth and job creation." }
      status { "active" }
      enacted_date { 18.months.ago }
    end
    factory :proposed_policy, traits: [:proposed]
    factory :under_review_policy, traits: [:under_review]
    factory :repealed_policy, traits: [:repealed]
    factory :education_policy_example, traits: [:education_policy]
    factory :healthcare_policy_example, traits: [:healthcare_policy]
    factory :transportation_policy_example, traits: [:transportation_policy]
    factory :environmental_policy_example, traits: [:environmental_policy]
    factory :housing_policy_example, traits: [:housing_policy]
    factory :economic_policy_example, traits: [:economic_policy]
    factory :temporary_policy_example, traits: [:temporary_policy]
    factory :federal_policy_example, traits: [:federal_policy]
    factory :state_policy_example, traits: [:state_policy]
    factory :local_policy_example, traits: [:local_policy]
  end
end

