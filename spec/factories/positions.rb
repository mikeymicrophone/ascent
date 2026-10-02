FactoryBot.define do
  factory :position do
    title { "City Council Member" }
    description { "Elected representative serving on the municipal council" }
    branch { :legislative }
    term_length_years { 4 }

    trait :executive do
      branch { :executive }
      title { "Mayor" }
      description { "Chief executive of the municipal government" }
    end

    trait :legislative do
      branch { :legislative }
      title { "Council Member" }
      description { "Legislative representative on the governing council" }
    end

    trait :judicial do
      branch { :judicial }
      title { "Justice" }
      description { "Member of a court, responsible for hearing cases and interpreting law" }
    end

    trait :mayor do
      branch { :executive }
      title { "Mayor" }
      description { "Chief executive officer of the city government" }
      term_length_years { 4 }
    end

    trait :governor do
      branch { :executive }
      title { "Governor" }
      description { "Chief executive officer of the state government" }
      term_length_years { 4 }
    end

    trait :president do
      branch { :executive }
      title { "President" }
      description { "Chief executive of the national government" }
      term_length_years { 4 }
    end

    trait :senator do
      branch { :legislative }
      title { "Senator" }
      description { "Member of the upper legislative chamber" }
      term_length_years { 6 }
    end

    trait :representative do
      branch { :legislative }
      title { "Representative" }
      description { "Member of the lower legislative chamber" }
      term_length_years { 2 }
    end

    trait :sheriff do
      branch { :executive }
      title { "Sheriff" }
      description { "Chief law enforcement officer for the county" }
      term_length_years { 4 }
    end

    trait :short_term do
      term_length_years { 2 }
    end

    trait :long_term do
      term_length_years { 6 }
    end

    # Named factories for common scenarios
    factory :executive_position, traits: [:executive]
    factory :legislative_position, traits: [:legislative]
    factory :judicial_position, traits: [:judicial]
    factory :mayor_position, traits: [:mayor]
    factory :governor_position, traits: [:governor]
    factory :president_position, traits: [:president]
    factory :senator_position, traits: [:senator]
    factory :representative_position, traits: [:representative]
    factory :sheriff_position, traits: [:sheriff]
  end
end
