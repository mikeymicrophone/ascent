FactoryBot.define do
  factory :election do
    office { nil }
    year { nil }
    election_date { "2025-06-19" }
    status { "MyString" }
    description { "MyText" }
    is_mock { false }
    is_historical { false }
  end
end
