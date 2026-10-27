FactoryBot.define do
  factory :channel do
    platform { "youtube" }
    sequence(:handle) { |n| "examplecampaign#{n}" }
    official { false }

    trait :official_website do
      platform { "website" }
      official { true }
      url { "https://example.com/campaign" }
    end
  end

  factory :communication do
    association :channel
    kind { "video" }
    title { "Town hall on school funding" }
    published_on { Date.new(2026, 9, 14) }
    sequence(:url) { |n| "https://example.com/campaign/videos/#{n}" }
  end

  factory :stance_evidence do
    association :stance
    association :communication
    relation { "states" }
    quote { "Every school should be funded by the same formula." }
    offset_seconds { 102 }
  end
end
