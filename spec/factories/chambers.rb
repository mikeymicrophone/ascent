FactoryBot.define do
  factory :chamber do
    name { "Senate" }
    description { "The upper house of a bicameral legislature." }
    association :governing_body, factory: :state_legislature_body

    trait :house do
      name { "House of Representatives" }
      description { "The lower house of a bicameral legislature." }
    end

    trait :assembly do
      name { "Assembly" }
      description { "The lower house of a bicameral state legislature." }
    end
  end
end
