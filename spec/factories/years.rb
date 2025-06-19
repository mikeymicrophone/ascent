FactoryBot.define do
  factory :year do
    year { 1 }
    is_even_year { false }
    is_presidential_year { false }
    description { "MyText" }
  end
end
