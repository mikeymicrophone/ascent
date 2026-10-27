FactoryBot.define do
  factory :state do
    name { Faker::Address.state }
    code { Faker::Address.state_abbr }
    association :country

    trait :with_jurisdiction do
      after(:create) { |place| create(:jurisdiction, jurisdictionable: place) }
    end
  end
end
