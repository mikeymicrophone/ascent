FactoryBot.define do
  factory :governing_body do
    name { "MyString" }
    jurisdiction_type { "MyString" }
    jurisdiction_id { 1 }
    governance_type { nil }
    description { "MyText" }
    meeting_schedule { "MyString" }
    is_active { false }
    established_date { "2025-06-21" }
  end
end
