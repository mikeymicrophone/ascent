FactoryBot.define do
  factory :candidacy do
    association :person
    association :election
    status { "active" }
    announcement_date { 6.months.ago }
    party_affiliation { "Independent" }
    platform_summary { "Committed to transparent governance and serving the community's best interests" }

    trait :active do
      status { "active" }
      announcement_date { 3.months.ago }
    end

    trait :withdrawn do
      status { "withdrawn" }
      announcement_date { 8.months.ago }
      platform_summary { "Campaign withdrawn due to personal reasons" }
    end

    trait :suspended do
      status { "suspended" }
      announcement_date { 4.months.ago }
      platform_summary { "Campaign temporarily suspended pending investigation" }
    end

    trait :democrat do
      party_affiliation { "Democratic Party" }
      platform_summary { "Progressive policies focused on social justice, healthcare, and environmental protection" }
    end

    trait :republican do
      party_affiliation { "Republican Party" }
      platform_summary { "Conservative values emphasizing fiscal responsibility, strong defense, and traditional values" }
    end

    trait :independent do
      party_affiliation { "Independent" }
      platform_summary { "Non-partisan approach focusing on practical solutions and community needs" }
    end

    trait :green do
      party_affiliation { "Green Party" }
      platform_summary { "Environmental sustainability, social justice, and grassroots democracy" }
    end

    trait :early_announcement do
      announcement_date { 1.year.ago }
    end

    trait :late_announcement do
      announcement_date { 1.month.ago }
    end

    # Named factories for common scenarios
    factory :active_candidacy, traits: [:active]
    factory :withdrawn_candidacy, traits: [:withdrawn]
    factory :democrat_candidacy, traits: [:active, :democrat]
    factory :republican_candidacy, traits: [:active, :republican]
    factory :independent_candidacy, traits: [:active, :independent]
    factory :green_candidacy, traits: [:active, :green]
    factory :early_candidacy, traits: [:active, :early_announcement]
    factory :late_candidacy, traits: [:active, :late_announcement]
  end
end
