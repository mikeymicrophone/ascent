FactoryBot.define do
  factory :municipality do
    name { Faker::Address.city }
    association :state
  end
end
