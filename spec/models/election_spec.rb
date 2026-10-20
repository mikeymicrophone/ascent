require "rails_helper"

RSpec.describe Election, type: :model do
  it "allows two events in the same jurisdiction on the same day" do
    election = create(:election)
    other = build(:election, jurisdiction: election.jurisdiction, election_date: election.election_date)

    expect(other).to be_valid
  end

  it "accepts unknown early-voting dates and an inclusive election-day endpoint" do
    election = build(:election, election_date: Date.new(2026, 11, 3))
    expect(election).to be_valid
    election.early_voting_ends_on = election.election_date
    expect(election).to be_valid
  end

  it "rejects reversed dates and a known endpoint after election day" do
    election = build(:election, election_date: Date.new(2026, 11, 3),
      early_voting_starts_on: Date.new(2026, 11, 2), early_voting_ends_on: Date.new(2026, 11, 1))
    expect(election).not_to be_valid
    expect(election.errors[:early_voting_ends_on]).to be_present

    election.early_voting_starts_on = nil
    election.early_voting_ends_on = Date.new(2026, 11, 4)
    expect(election).not_to be_valid
  end

  it "keeps Race cancellation independent of the event and other races" do
    election = create(:election, :active)
    cancelled = create(:race, :active, election: election)
    continuing = create(:race, :active, election: election)
    cancelled.update!(status: "cancelled")

    expect(election.reload.status).to eq("active")
    expect(continuing.reload.status).to eq("active")
  end
end
