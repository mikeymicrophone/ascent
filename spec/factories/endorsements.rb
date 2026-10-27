FactoryBot.define do
  # A public endorsement entered independently of the ballot. Strength runs from 1 (a mention) to
  # 5 (a headline endorsement); 4 and above count as major.
  factory :endorsement do
    association :candidacy
    association :endorser, factory: :organization
    kind { "public" }
    strength { 3 }
    endorsed_on { Date.new(2026, 9, 15) }
    notes { "Announced at a candidate forum" }

    trait :major do
      strength { 5 }
      notes { "Front-page editorial endorsement" }
    end

    trait :minor do
      strength { 1 }
      notes { "Listed among several candidates the group finds acceptable" }
    end

    trait :withdrawn do
      withdrawn_on { Date.new(2026, 10, 1) }
      notes { "Withdrawn after the candidate changed position" }
    end
  end
end
