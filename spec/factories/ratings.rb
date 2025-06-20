FactoryBot.define do
  factory :rating do
    association :voter
    association :candidacy
    rating { Faker::Number.between(from: 0, to: 500) }
    created_at { Faker::Time.between(from: 6.months.ago, to: Time.current) }
    updated_at { created_at + rand(1.hour..1.week) }

    trait :strongly_approve do
      rating { Faker::Number.between(from: 400, to: 500) }
    end

    trait :approve do
      rating { Faker::Number.between(from: 300, to: 399) }
    end

    trait :neutral do
      rating { Faker::Number.between(from: 200, to: 299) }
    end

    trait :disapprove do
      rating { Faker::Number.between(from: 100, to: 199) }
    end

    trait :strongly_disapprove do
      rating { Faker::Number.between(from: 0, to: 99) }
    end

    trait :maximum do
      rating { 500 }
    end

    trait :minimum do
      rating { 0 }
    end

    trait :recent do
      created_at { Faker::Time.between(from: 1.week.ago, to: Time.current) }
      updated_at { created_at + rand(1.hour..2.days) }
    end

    trait :historic do
      created_at { Faker::Time.between(from: 2.years.ago, to: 6.months.ago) }
      updated_at { created_at + rand(1.week..6.months) }
    end

    trait :polarized do
      rating { 
        # Generate polarized ratings (mostly very high or very low)
        rand < 0.5 ? Faker::Number.between(from: 0, to: 100) : Faker::Number.between(from: 400, to: 500)
      }
    end

    trait :moderate do
      rating { Faker::Number.between(from: 150, to: 350) }
    end

    trait :high_variance do
      rating { 
        # Create clusters around certain values to simulate realistic voter behavior
        clusters = [50, 150, 250, 350, 450]
        base = clusters.sample
        base + rand(-30..30)
      }
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
    factory :polarized_rating, traits: [:polarized]
    factory :moderate_rating, traits: [:moderate]
    factory :realistic_rating, traits: [:high_variance]
  end
end
