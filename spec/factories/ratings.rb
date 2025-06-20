FactoryBot.define do
  factory :rating do
    association :voter
    association :candidacy
    rating { 250 } # Neutral rating on 0-500 scale

    trait :strongly_approve do
      rating { 450 }
    end

    trait :approve do
      rating { 350 }
    end

    trait :neutral do
      rating { 250 }
    end

    trait :disapprove do
      rating { 150 }
    end

    trait :strongly_disapprove do
      rating { 50 }
    end

    trait :maximum do
      rating { 500 }
    end

    trait :minimum do
      rating { 0 }
    end

    trait :recent do
      created_at { 1.week.ago }
      updated_at { 1.week.ago }
    end

    trait :historic do
      created_at { 2.years.ago }
      updated_at { 1.year.ago }
    end

    # Named factories for common scenarios
    factory :approval_rating, traits: [:approve]
    factory :disapproval_rating, traits: [:disapprove]
    factory :strong_approval_rating, traits: [:strongly_approve]
    factory :strong_disapproval_rating, traits: [:strongly_disapprove]
    factory :neutral_rating, traits: [:neutral]
    factory :maximum_rating, traits: [:maximum]
    factory :minimum_rating, traits: [:minimum]
    factory :recent_rating, traits: [:recent, :approve]
    factory :historic_rating, traits: [:historic, :neutral]
  end
end
