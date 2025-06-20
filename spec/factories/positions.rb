FactoryBot.define do
  factory :position do
    title { "City Council Member" }
    description { "Elected representative serving on the municipal council" }
    is_executive { false }
    term_length_years { 4 }

    trait :executive do
      is_executive { true }
      title { "Mayor" }
      description { "Chief executive of the municipal government" }
    end

    trait :legislative do
      is_executive { false }
      title { "Council Member" }
      description { "Legislative representative on the governing council" }
    end

    trait :judicial do
      is_executive { false }
      title { "Judge" }
      description { "Judicial officer presiding over legal proceedings" }
    end

    trait :mayor do
      is_executive { true }
      title { "Mayor" }
      description { "Chief executive officer of the city government" }
      term_length_years { 4 }
    end

    trait :governor do
      is_executive { true }
      title { "Governor" }
      description { "Chief executive officer of the state government" }
      term_length_years { 4 }
    end

    trait :president do
      is_executive { true }
      title { "President" }
      description { "Chief executive of the national government" }
      term_length_years { 4 }
    end

    trait :senator do
      is_executive { false }
      title { "Senator" }
      description { "Member of the upper legislative chamber" }
      term_length_years { 6 }
    end

    trait :representative do
      is_executive { false }
      title { "Representative" }
      description { "Member of the lower legislative chamber" }
      term_length_years { 2 }
    end

    trait :sheriff do
      is_executive { true }
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
