FactoryBot.define do
  # A certified count for one candidacy in a finished race, shown after a voter replays it.
  factory :official_result do
    association :candidacy
    race { candidacy.race }
    votes { 12_480 }
    vote_share { 38.6 }
    winner { false }

    trait :winner do
      votes { 18_204 }
      vote_share { 52.1 }
      winner { true }
    end
  end
end
