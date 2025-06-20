FactoryBot.define do
  factory :voter do
    sequence(:email) { |n| "voter#{n}@example.com" }
    first_name { "Jane" }
    last_name { "Smith" }
    password { "password123" }
    password_confirmation { "password123" }
    confirmed_at { Time.current }

    trait :verified do
      # Voter has completed verification process
      first_name { "Emily" }
      last_name { "Johnson" }
      email { "emily.verified@example.com" }
    end

    trait :unverified do
      # New voter, not yet verified
      first_name { "Alex" }
      last_name { "Wilson" }
      email { "alex.unverified@example.com" }
      confirmed_at { nil }
    end

    trait :experienced do
      # Long-time voter with established history
      first_name { "Robert" }
      last_name { "Davis" }
      email { "robert.experienced@example.com" }
      created_at { 10.years.ago }
    end

    trait :student do
      # College-age voter
      first_name { "Sarah" }
      last_name { "Martinez" }
      email { "sarah.student@example.com" }
      created_at { 2.years.ago }
    end

    trait :mobile do
      # Voter who moves frequently
      first_name { "Michael" }
      last_name { "Chen" }
      email { "michael.mobile@example.com" }
    end

    # Named factories for common scenarios
    factory :verified_voter, traits: [:verified]
    factory :unverified_voter, traits: [:unverified]
    factory :experienced_voter, traits: [:experienced]
    factory :student_voter, traits: [:student]
    factory :mobile_voter, traits: [:mobile]
  end
end
