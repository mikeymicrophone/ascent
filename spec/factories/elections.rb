FactoryBot.define do
  factory :election do
    association :office
    association :year
    election_date { 1.year.from_now }
    status { "upcoming" }
    description { "General election for public office" }
    is_mock { false }
    is_historical { false }

    trait :upcoming do
      status { "upcoming" }
      election_date { 6.months.from_now }
      description { "Upcoming election with active candidate registration" }
    end

    trait :active do
      status { "active" }
      election_date { 1.month.from_now }
      description { "Active election period with voting in progress" }
    end

    trait :completed do
      status { "completed" }
      election_date { 3.months.ago }
      description { "Completed election with certified results" }
    end

    trait :cancelled do
      status { "cancelled" }
      election_date { 2.months.from_now }
      description { "Election cancelled due to exceptional circumstances" }
    end

    trait :mock do
      is_mock { true }
      description { "Mock election for testing approval voting system" }
      election_date { 1.week.from_now }
    end

    trait :historical do
      is_historical { true }
      status { "completed" }
      election_date { 4.years.ago }
      description { "Historical election data for research and analysis" }
    end

    trait :local do
      description { "Local municipal election for city council or mayor" }
    end

    trait :state do
      description { "State-level election for governor or state legislature" }
    end

    trait :national do
      description { "National election for federal offices" }
    end

    trait :recent do
      election_date { 2.months.ago }
      status { "completed" }
    end

    trait :distant_future do
      election_date { 2.years.from_now }
      status { "planned" }
    end

    # Named factories for common scenarios
    factory :upcoming_election, traits: [:upcoming]
    factory :active_election, traits: [:active]
    factory :completed_election, traits: [:completed]
    factory :mock_election, traits: [:mock]
    factory :historical_election, traits: [:historical]
    factory :local_election, traits: [:upcoming, :local]
    factory :state_election, traits: [:upcoming, :state]
    factory :national_election, traits: [:upcoming, :national]
    factory :recent_election, traits: [:recent]
  end
end
