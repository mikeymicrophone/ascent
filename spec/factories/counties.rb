FactoryBot.define do
  factory :county do
    name { "#{Faker::Address.city} County" }
    association :state

    trait :with_jurisdiction do
      after(:create) { |place| create(:jurisdiction, jurisdictionable: place) }
    end
  end
end
