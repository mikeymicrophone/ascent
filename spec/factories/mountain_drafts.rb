FactoryBot.define do
  # Unsaved changes to one voter's mountain: ratings keyed by candidacy id, and maybe a baseline.
  factory :mountain_draft do
    association :voter
    association :race
    baseline { nil }
    ratings { {} }

    trait :with_baseline do
      baseline { 260 }
    end
  end
end
