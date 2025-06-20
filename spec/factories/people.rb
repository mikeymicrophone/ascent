FactoryBot.define do
  factory :person do
    first_name { "John" }
    last_name { "Doe" }
    middle_name { "Robert" }
    sequence(:email) { |n| "person#{n}@example.com" }
    birth_date { 45.years.ago }
    bio { "Dedicated public servant committed to representing the community's interests" }

    trait :young_candidate do
      first_name { "Alexandra" }
      last_name { "Young" }
      middle_name { "Marie" }
      birth_date { 28.years.ago }
      bio { "Young professional bringing fresh perspectives and innovative solutions to local government" }
    end

    trait :experienced_politician do
      first_name { "Robert" }
      last_name { "Senior" }
      middle_name { "James" }
      birth_date { 60.years.ago }
      bio { "Veteran politician with 25+ years of experience in public service and legislative leadership" }
    end

    trait :business_leader do
      first_name { "Margaret" }
      last_name { "Entrepreneur" }
      middle_name { "Elizabeth" }
      birth_date { 52.years.ago }
      bio { "Successful business leader transitioning to public service to bring private sector efficiency to government" }
    end

    trait :community_activist do
      first_name { "David" }
      last_name { "Advocate" }
      middle_name { "Michael" }
      birth_date { 38.years.ago }
      bio { "Grassroots organizer and community activist with deep roots in local social justice movements" }
    end

    trait :educator do
      first_name { "Susan" }
      last_name { "Teacher" }
      middle_name { "Ann" }
      birth_date { 42.years.ago }
      bio { "Former school principal and education advocate focused on improving public education funding and quality" }
    end

    trait :veteran do
      first_name { "James" }
      last_name { "Military" }
      middle_name { "William" }
      birth_date { 48.years.ago }
      bio { "Military veteran with leadership experience seeking to serve the community through public office" }
    end

    trait :no_middle_name do
      middle_name { nil }
    end

    trait :long_bio do
      bio { "Extensive biography detailing decades of community involvement, professional achievements, educational background, family commitments, and comprehensive policy positions on key issues affecting the constituency." }
    end

    trait :minimal_bio do
      bio { "Candidate for public office." }
    end

    # Named factories for common scenarios
    factory :young_candidate, traits: [:young_candidate]
    factory :experienced_politician, traits: [:experienced_politician]
    factory :business_leader, traits: [:business_leader]
    factory :community_activist, traits: [:community_activist]
    factory :educator_candidate, traits: [:educator]
    factory :veteran_candidate, traits: [:veteran]
    factory :person_no_middle_name, traits: [:no_middle_name]
  end
end
