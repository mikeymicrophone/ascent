FactoryBot.define do
  factory :race do
    association :election
    office { association :office, jurisdiction: election.jurisdiction }
    status { 'upcoming' }

    trait :active do
      status { 'active' }
    end

    trait :completed do
      status { 'completed' }
    end

    trait :cancelled do
      status { 'cancelled' }
    end

    trait :mock do
      association :election, factory: [ :election, :mock ]
    end

    trait :historical do
      association :election, factory: [ :election, :historical ]
    end

    trait :local do
      association :election, factory: [ :election, :local ]
    end

    trait :national do
      association :election, factory: [ :election, :national ]
    end
  end
end
