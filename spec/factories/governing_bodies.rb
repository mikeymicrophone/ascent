FactoryBot.define do
  factory :governing_body do
    name { "City Council" }
    jurisdiction_type { "City" }
    association :jurisdiction, factory: :city
    association :governance_type
    description { "The legislative body responsible for local ordinances, budget approval, and municipal policy decisions that impact daily life of city residents." }
    meeting_schedule { "Weekly" }
    is_active { true }
    established_date { 50.years.ago }

    # Federal level bodies
    trait :federal_legislature do
      name { "United States Congress" }
      jurisdiction_type { "Country" }
      association :jurisdiction, factory: :country
      association :governance_type, factory: :governance_type, name: "Federal Legislature"
      description { "The bicameral legislature of the federal government consisting of the House of Representatives and the Senate, responsible for making federal laws and appropriating the national budget." }
      meeting_schedule { "Year-round with recesses" }
      established_date { Date.new(1789, 3, 4) }
    end

    trait :federal_executive do
      name { "Executive Office of the President" }
      jurisdiction_type { "Country" }
      association :jurisdiction, factory: :country
      association :governance_type, factory: :governance_type, name: "Federal Executive"
      description { "The executive branch of the United States federal government, headed by the President, responsible for implementing and enforcing federal laws and policies." }
      meeting_schedule { "Continuous" }
      established_date { Date.new(1789, 4, 30) }
    end

    # State level bodies
    trait :state_legislature do
      name { "State Legislature" }
      jurisdiction_type { "State" }
      association :jurisdiction, factory: :state
      association :governance_type, factory: :governance_type, name: "State Legislature"
      description { "The state legislative body responsible for making state laws, appropriating the state budget, and overseeing state executive agencies." }
      meeting_schedule { "Annual sessions" }
      established_date { 100.years.ago }
    end

    trait :state_executive do
      name { "Office of the Governor" }
      jurisdiction_type { "State" }
      association :jurisdiction, factory: :state
      association :governance_type, factory: :governance_type, name: "State Executive"
      description { "The executive branch of state government, headed by the Governor, responsible for implementing state policy and managing state operations." }
      meeting_schedule { "Continuous" }
      established_date { 100.years.ago }
    end

    # Municipal level bodies
    trait :municipal_legislature do
      name { "City Council" }
      jurisdiction_type { "City" }
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "Municipal Legislature"
      description { "The legislative body of the city, responsible for local ordinances, budget approval, and municipal policy that directly affects residents' daily lives." }
      meeting_schedule { "Weekly" }
      established_date { 75.years.ago }
    end

    trait :county_executive do
      name { "County Executive" }
      jurisdiction_type { "City" } # Using city as proxy for county
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "County Executive"
      description { "The chief executive officer of the county, responsible for implementing county policies, managing county operations, and coordinating regional services." }
      meeting_schedule { "As needed" }
      established_date { 60.years.ago }
    end

    trait :county_legislature do
      name { "County Legislature" }
      jurisdiction_type { "City" } # Using city as proxy for county
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "County Legislature"
      description { "The legislative body of the county, responsible for county ordinances, budget oversight, and regional policy coordination across municipalities." }
      meeting_schedule { "Monthly" }
      established_date { 80.years.ago }
    end

    # Educational bodies
    trait :school_board do
      name { "School District Board" }
      jurisdiction_type { "City" }
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "School Board"
      description { "The governing board responsible for educational policy, budget oversight, superintendent selection, and ensuring quality education for all students in the district." }
      meeting_schedule { "Monthly" }
      established_date { 90.years.ago }
    end

    # Special districts
    trait :special_district do
      name { "Special District Board" }
      jurisdiction_type { "City" }
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "Special District Board"
      description { "The governing board of a special purpose district providing specific services like transit, water, fire protection, or other specialized public services." }
      meeting_schedule { "Bi-weekly" }
      established_date { 40.years.ago }
    end

    trait :transit_district do
      name { "Transit Authority Board" }
      jurisdiction_type { "City" }
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "Special District Board"
      description { "The governing board responsible for public transit policy, fare setting, service planning, and system expansion to serve regional transportation needs." }
      meeting_schedule { "Bi-weekly" }
      established_date { 50.years.ago }
    end

    trait :water_district do
      name { "Water District Board" }
      jurisdiction_type { "City" }
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "Special District Board"
      description { "The governing board responsible for water supply management, infrastructure maintenance, conservation programs, and ensuring reliable water service." }
      meeting_schedule { "Monthly" }
      established_date { 70.years.ago }
    end

    trait :fire_district do
      name { "Fire Protection District Board" }
      jurisdiction_type { "City" }
      association :jurisdiction, factory: :city
      association :governance_type, factory: :governance_type, name: "Special District Board"
      description { "The governing board responsible for fire protection services, emergency response, fire prevention programs, and public safety in the district." }
      meeting_schedule { "Monthly" }
      established_date { 65.years.ago }
    end

    # Authority level traits
    trait :local_authority do
      jurisdiction_type { "City" }
      association :jurisdiction, factory: :city
    end

    trait :regional_authority do
      jurisdiction_type { "State" }
      association :jurisdiction, factory: :state
    end

    trait :state_authority do
      jurisdiction_type { "State" }
      association :jurisdiction, factory: :state
    end

    trait :federal_authority do
      jurisdiction_type { "Country" }
      association :jurisdiction, factory: :country
    end

    # Activity status traits
    trait :active do
      is_active { true }
    end

    trait :inactive do
      is_active { false }
      description { description + " This body is currently inactive and not conducting regular business." }
    end

    # Meeting frequency traits
    trait :weekly_meetings do
      meeting_schedule { "Weekly" }
    end

    trait :monthly_meetings do
      meeting_schedule { "Monthly" }
    end

    trait :quarterly_meetings do
      meeting_schedule { "Quarterly" }
    end

    trait :annual_meetings do
      meeting_schedule { "Annual sessions" }
    end

    trait :continuous_operation do
      meeting_schedule { "Continuous" }
    end

    # Historical periods
    trait :historical do
      established_date { 150.years.ago }
      description { description + " This is a long-established institution with significant historical importance to the community." }
    end

    trait :modern do
      established_date { 20.years.ago }
      description { description + " This is a recently established governing body created to address contemporary governance needs." }
    end

    trait :recent do
      established_date { 5.years.ago }
      description { description + " This newly formed governing body was created to address emerging community needs and services." }
    end

    # Named factories for common scenarios
    factory :federal_congress, traits: [:federal_legislature, :active]
    factory :federal_executive_office, traits: [:federal_executive, :active]
    factory :state_legislature_body, traits: [:state_legislature, :active]
    factory :state_governor_office, traits: [:state_executive, :active]
    factory :city_council, traits: [:municipal_legislature, :active]
    factory :county_executive_office, traits: [:county_executive, :active]
    factory :county_legislature_body, traits: [:county_legislature, :active]
    factory :school_district_board, traits: [:school_board, :active]
    factory :transit_authority, traits: [:transit_district, :active]
    factory :water_district_board, traits: [:water_district, :active]
    factory :fire_district_board, traits: [:fire_district, :active]
    factory :special_district_board, traits: [:special_district, :active]
    
    # Historical variations
    factory :historical_city_council, traits: [:municipal_legislature, :historical, :active]
    factory :modern_transit_authority, traits: [:transit_district, :modern, :active]
    factory :inactive_governing_body, traits: [:municipal_legislature, :inactive]
  end
end
