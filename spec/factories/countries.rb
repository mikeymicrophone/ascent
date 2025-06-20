FactoryBot.define do
  factory :country do
    name { Faker::Address.country }
    code { Faker::Address.country_code }
    description { "Country for testing purposes" }
  end
end
