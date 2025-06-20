FactoryBot.define do
  factory :residence do
    association :voter
    association :jurisdiction, factory: :city
    registered_at { 3.years.ago }
    status { "active" }
    notes { "Standard residence registration for voting purposes" }

    trait :active do
      status { "active" }
      registered_at { 2.years.ago }
      notes { "Current active residence for voter eligibility" }
    end

    trait :inactive do
      status { "inactive" }
      registered_at { 5.years.ago }
      notes { "Previous residence, voter has since moved" }
    end

    trait :moved do
      status { "moved" }
      registered_at { 4.years.ago }
      notes { "Residence ended due to relocation to new jurisdiction" }
    end

    trait :suspended do
      status { "suspended" }
      registered_at { 1.year.ago }
      notes { "Residence temporarily suspended pending verification" }
    end

    trait :in_state do
      association :jurisdiction, factory: :state
      notes { "State-level residence registration" }
    end

    trait :in_country do
      association :jurisdiction, factory: :country
      notes { "Country-level residence registration for national elections" }
    end

    # Commonly used combinations
    factory :active_city_residence, traits: [:active]
    factory :inactive_residence, traits: [:inactive]
    factory :moved_residence, traits: [:moved]
    factory :state_residence, traits: [:active, :in_state]
    factory :country_residence, traits: [:active, :in_country]
  end
end