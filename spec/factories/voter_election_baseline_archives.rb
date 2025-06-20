FactoryBot.define do
  factory :voter_election_baseline_archive do
    association :voter
    association :election
    baseline { Faker::Number.between(from: 100, to: 400) }
    archived_at { Faker::Time.between(from: 1.month.ago, to: Time.current) }
    reason { "Baseline changed during testing" }
    previous_baseline { Faker::Number.between(from: 100, to: 400) }
    new_baseline { Faker::Number.between(from: 100, to: 400) }

    trait :baseline_increase do
      previous_baseline { 200 }
      new_baseline { 300 }
      baseline { previous_baseline }
      reason { "Baseline increased from #{previous_baseline} to #{new_baseline}" }
    end

    trait :baseline_decrease do
      previous_baseline { 350 }
      new_baseline { 250 }
      baseline { previous_baseline }
      reason { "Baseline decreased from #{previous_baseline} to #{new_baseline}" }
    end

    trait :baseline_deleted do
      previous_baseline { 275 }
      new_baseline { nil }
      baseline { previous_baseline }
      reason { "Baseline deleted (was #{previous_baseline})" }
    end

    trait :recent_change do
      archived_at { Faker::Time.between(from: 1.day.ago, to: Time.current) }
    end

    trait :historic_change do
      archived_at { Faker::Time.between(from: 6.months.ago, to: 1.month.ago) }
    end

    trait :large_change do
      previous_baseline { 200 }
      new_baseline { 400 }
      baseline { previous_baseline }
      reason { "Major baseline adjustment from #{previous_baseline} to #{new_baseline}" }
    end

    trait :minor_change do
      previous_baseline { 250 }
      new_baseline { 275 }
      baseline { previous_baseline }
      reason { "Minor baseline adjustment from #{previous_baseline} to #{new_baseline}" }
    end

    # Named factories for common scenarios
    factory :baseline_increase_archive, traits: [:baseline_increase]
    factory :baseline_decrease_archive, traits: [:baseline_decrease]
    factory :baseline_deletion_archive, traits: [:baseline_deleted]
    factory :recent_baseline_change, traits: [:recent_change, :baseline_increase]
    factory :historic_baseline_change, traits: [:historic_change, :baseline_decrease]
    factory :major_baseline_change, traits: [:large_change]
    factory :minor_baseline_change, traits: [:minor_change]
  end
end