FactoryBot.define do
  factory :position do
    title { "MyString" }
    description { "MyText" }
    is_executive { false }
    term_length_years { 1 }
  end
end
