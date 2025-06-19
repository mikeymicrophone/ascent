FactoryBot.define do
  factory :voter_election_baseline do
    voter { nil }
    election { nil }
    baseline { 1 }
  end
end
