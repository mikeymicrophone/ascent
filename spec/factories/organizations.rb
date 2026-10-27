FactoryBot.define do
  factory :organization do
    sequence(:name) { |n| "Harbor Civic League #{n}" }
    kind { "civic" }

    trait :union do
      name { "Harbor Workers Union Local 12" }
      kind { "union" }
    end

    trait :media do
      name { "Port Merritt Ledger" }
      kind { "media" }
    end

    trait :advocacy do
      name { "Calder Clean Water Coalition" }
      kind { "advocacy" }
    end
  end
end
