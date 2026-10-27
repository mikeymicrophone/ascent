FactoryBot.define do
  factory :district do
    name { "#{Faker::Address.city} District" }
    kind { 'legislative' }

    trait :with_jurisdiction do
      after(:create) { |place| create(:jurisdiction, jurisdictionable: place) }
    end
  end
end
