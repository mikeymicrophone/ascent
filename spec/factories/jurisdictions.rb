FactoryBot.define do
  factory :jurisdiction do
    association :jurisdictionable, factory: :municipality

    trait :country do
      association :jurisdictionable, factory: :country
    end

    trait :state do
      association :jurisdictionable, factory: :state
    end

    trait :county do
      association :jurisdictionable, factory: :county
    end

    trait :district do
      association :jurisdictionable, factory: :district
    end
  end
end
