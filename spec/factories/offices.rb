FactoryBot.define do
  factory :office do
    position { nil }
    jurisdiction { nil }
    is_active { false }
    notes { "MyText" }
  end
end
