FactoryBot.define do
  factory :candidacy do
    person { nil }
    election { nil }
    status { "MyString" }
    announcement_date { "2025-06-19" }
    party_affiliation { "MyString" }
    platform_summary { "MyText" }
  end
end
