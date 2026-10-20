FactoryBot.define do
  factory :district do
    name { "#{Faker::Address.city} District" }
    kind { 'legislative' }
  end
end
