FactoryBot.define do
  factory :rating_archive do
    voter { nil }
    candidacy { nil }
    rating { 1 }
    baseline { 1 }
    archived_at { "2025-06-19 17:51:19" }
    reason { "MyString" }
  end
end
