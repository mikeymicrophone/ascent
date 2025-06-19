FactoryBot.define do
  factory :registration do
    voter { nil }
    jurisdiction { nil }
    registered_at { "2025-06-19 17:50:42" }
    status { "MyString" }
    notes { "MyText" }
  end
end
