FactoryBot.define do
  factory :voter_election_baseline do
    association :voter
    association :election
    baseline { 250 } # Neutral baseline on 0-500 scale

    trait :high_standards do
      baseline { 400 }
    end

    trait :moderate_standards do
      baseline { 300 }
    end

    trait :average_standards do
      baseline { 250 }
    end

    trait :low_standards do
      baseline { 150 }
    end

    trait :very_low_standards do
      baseline { 100 }
    end

    trait :maximum_standards do
      baseline { 500 }
    end

    trait :minimum_standards do
      baseline { 0 }
    end

    trait :for_local_election do
      association :election, factory: [:election, :local]
      baseline { 200 } # Lower standards for local elections
    end

    trait :for_national_election do
      association :election, factory: [:election, :national]
      baseline { 350 } # Higher standards for national elections
    end

    # Named factories for common scenarios
    factory :high_standards_baseline, traits: [:high_standards]
    factory :moderate_baseline, traits: [:moderate_standards]
    factory :low_standards_baseline, traits: [:low_standards]
    factory :local_election_baseline, traits: [:for_local_election]
    factory :national_election_baseline, traits: [:for_national_election]
  end
end
