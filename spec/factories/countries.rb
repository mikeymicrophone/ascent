FactoryBot.define do
  factory :country do
    name { Faker::Address.country }
    code { Faker::Address.country_code }
    description { "Country for testing purposes" }

    trait :with_jurisdiction do
      after(:create) { |place| create(:jurisdiction, jurisdictionable: place) }
    end
  end
end
