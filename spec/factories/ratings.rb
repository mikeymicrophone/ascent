FactoryBot.define do
  factory :rating do
    voter { nil }
    candidacy { nil }
    rating { 1 }
    baseline { 1 }
  end
end
