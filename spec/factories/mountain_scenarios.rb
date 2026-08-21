# Product-oriented factories for making the Mountain visible in development and specs.
#
# These deliberately create shaped preference data rather than independent random
# ratings. A mountain is interesting because the ratings relate to one another and
# to the voter's baseline.
FactoryBot.define do
  factory :mountain_scenario, class: Hash do
    transient do
      election { association :election, :mock }
      voter { association :voter }
      candidate_count { 8 }
      baseline { 275 }
      ratings { [470, 425, 365, 310, 265, 205, 125, 55] }
    end

    initialize_with do
      candidacies = Array.new(candidate_count) do |index|
        person = create(
          :person,
          first_name: %w[Avery Blair Cameron Devon Ellis Finley Gray Harper Jordan Kai Morgan Parker Quinn Riley Sawyer Taylor][index],
          last_name: "Candidate"
        )
        create(:candidacy, election: election, person: person)
      end

      voter_baseline = create(
        :voter_election_baseline,
        voter: voter,
        election: election,
        baseline: baseline
      )

      created_ratings = candidacies.each_with_index.map do |candidacy, index|
        create(
          :rating,
          voter: voter,
          candidacy: candidacy,
          rating: ratings.fetch(index) { [baseline + rand(-180..180), 0].max.clamp(0, 500) }
        )
      end

      {
        election: election,
        voter: voter,
        candidacies: candidacies,
        baseline: voter_baseline,
        ratings: created_ratings
      }
    end

    trait :crowded_primary do
      candidate_count { 12 }
      baseline { 285 }
      ratings { [485, 455, 420, 385, 350, 315, 295, 275, 235, 185, 120, 45] }
    end

    # Demonstrates the central product insight: a voter can have several candidates
    # clustered around the approval line without pretending to feel differently
    # about them. Moving the line changes the ballot, not the underlying feelings.
    trait :knife_edge do
      candidate_count { 8 }
      baseline { 300 }
      ratings { [465, 405, 335, 307, 294, 275, 160, 70] }
    end

    trait :enthusiastic do
      candidate_count { 8 }
      baseline { 225 }
      ratings { [490, 450, 410, 365, 320, 270, 215, 125] }
    end

    trait :selective do
      candidate_count { 8 }
      baseline { 365 }
      ratings { [480, 420, 355, 315, 265, 210, 145, 75] }
    end

    trait :polarized do
      candidate_count { 8 }
      baseline { 250 }
      ratings { [495, 465, 430, 380, 115, 80, 35, 5] }
    end

    factory :crowded_primary_mountain, traits: [:crowded_primary]
    factory :knife_edge_mountain, traits: [:knife_edge]
    factory :enthusiastic_mountain, traits: [:enthusiastic]
    factory :selective_mountain, traits: [:selective]
    factory :polarized_mountain, traits: [:polarized]
  end
end
