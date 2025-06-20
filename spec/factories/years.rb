FactoryBot.define do
  factory :year do
    sequence(:year) { |n| 2020 + n }
    is_even_year { year.even? }
    is_presidential_year { year % 4 == 0 }
    description { "Election year #{year}" }
  end
end
