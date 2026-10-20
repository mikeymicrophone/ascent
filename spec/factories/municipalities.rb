FactoryBot.define do
  factory :municipality do
    name { Faker::Address.city }
    association :state

    trait :with_jurisdiction do
      after(:create) { |place| create(:jurisdiction, jurisdictionable: place) }
    end
  end
end
