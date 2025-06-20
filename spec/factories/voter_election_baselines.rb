FactoryBot.define do
  factory :voter_election_baseline do
    association :voter
    association :election
    baseline { Faker::Number.between(from: 150, to: 350) } # Most voters have moderate baselines

    trait :high_standards do
      baseline { Faker::Number.between(from: 350, to: 450) }
    end

    trait :moderate_standards do
      baseline { Faker::Number.between(from: 250, to: 349) }
    end

    trait :average_standards do
      baseline { Faker::Number.between(from: 200, to: 299) }
    end

    trait :low_standards do
      baseline { Faker::Number.between(from: 100, to: 199) }
    end

    trait :very_low_standards do
      baseline { Faker::Number.between(from: 50, to: 149) }
    end

    trait :maximum_standards do
      baseline { Faker::Number.between(from: 450, to: 500) }
    end

    trait :minimum_standards do
      baseline { Faker::Number.between(from: 0, to: 99) }
    end

    trait :realistic_distribution do
      baseline { 
        # Generate realistic baseline distribution
        # Most voters cluster around 200-300, with fewer at extremes
        case rand(100)
        when 0..5   # 6% very low
          Faker::Number.between(from: 50, to: 150)
        when 6..20  # 15% low
          Faker::Number.between(from: 150, to: 200)
        when 21..70 # 50% moderate
          Faker::Number.between(from: 200, to: 300)
        when 71..90 # 20% high
          Faker::Number.between(from: 300, to: 400)
        else        # 9% very high
          Faker::Number.between(from: 400, to: 500)
        end
      }
    end

    trait :election_type_adjusted do
      baseline { 
        # Adjust baseline based on election importance
        base_value = Faker::Number.between(from: 150, to: 350)
        
        # Add variance based on voter personality
        personality_modifier = case rand(5)
        when 0 # Very demanding voter
          50
        when 1 # Demanding voter  
          25
        when 2 # Average voter
          0
        when 3 # Lenient voter
          -25
        else   # Very lenient voter
          -50
        end
        
        [base_value + personality_modifier, 0].max.to_i.clamp(0, 500)
      }
    end

    trait :for_local_election do
      association :election, factory: [:election, :local]
      baseline { Faker::Number.between(from: 150, to: 250) } # Lower standards for local elections
    end

    trait :for_national_election do
      association :election, factory: [:election, :national]
      baseline { Faker::Number.between(from: 250, to: 400) } # Higher standards for national elections
    end

    # Named factories for common scenarios
    factory :high_standards_baseline, traits: [:high_standards]
    factory :moderate_baseline, traits: [:moderate_standards]
    factory :low_standards_baseline, traits: [:low_standards]
    factory :realistic_baseline, traits: [:realistic_distribution]
    factory :personality_based_baseline, traits: [:election_type_adjusted]
    factory :local_election_baseline, traits: [:for_local_election]
    factory :national_election_baseline, traits: [:for_national_election]
  end
end
