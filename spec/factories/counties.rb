FactoryBot.define do
  factory :county do
    name { "#{Faker::Address.city} County" }
    association :state
  end
end
