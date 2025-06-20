FactoryBot.define do
  factory :office do
    association :position
    association :jurisdiction, factory: :city
    is_active { true }
    notes { "Active political office available for election" }

    trait :active do
      is_active { true }
      notes { "Currently active office with regular elections" }
    end

    trait :inactive do
      is_active { false }
      notes { "Office temporarily suspended or abolished" }
    end

    trait :city_level do
      association :jurisdiction, factory: :city
      notes { "Municipal office serving city residents" }
    end

    trait :state_level do
      association :jurisdiction, factory: :state
      notes { "State office serving all state residents" }
    end

    trait :country_level do
      association :jurisdiction, factory: :country
      notes { "National office serving the entire country" }
    end

    trait :executive do
      association :position, factory: [:position, :executive]
      notes { "Executive branch office with administrative responsibilities" }
    end

    trait :legislative do
      association :position, factory: [:position, :legislative]
      notes { "Legislative office involved in lawmaking and policy" }
    end

    trait :judicial do
      association :position, factory: [:position, :judicial]
      notes { "Judicial office responsible for legal interpretation" }
    end

    trait :term_limited do
      notes { "Office with term limits restricting consecutive service" }
    end

    trait :appointed do
      notes { "Appointed office, not directly elected by voters" }
    end

    # Named factories for common scenarios
    factory :active_office, traits: [:active]
    factory :inactive_office, traits: [:inactive]
    factory :city_office, traits: [:active, :city_level]
    factory :state_office, traits: [:active, :state_level]
    factory :national_office, traits: [:active, :country_level]
    factory :executive_office, traits: [:active, :executive]
    factory :legislative_office, traits: [:active, :legislative]
    factory :judicial_office, traits: [:active, :judicial]
  end
end
