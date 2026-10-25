require 'rails_helper'

# A mountain holds one voter's ratings and baseline, so only that voter, or an admin, may open or
# change it, and only admins may fill a race with simulated candidates and ratings.
RSpec.describe "Mountain access", type: :request do
  let!(:race) { create(:race, :active) }
  let!(:candidacy) { create(:candidacy, race: race, status: "active") }
  let(:voter) { create(:voter, first_name: "Priya", last_name: "Raman") }
  let(:neighbor) { create(:voter, first_name: "Tomas", last_name: "Lind") }
  let(:admin) { create(:voter, first_name: "Ada", last_name: "Okoye", admin: true) }

  it "sends a visitor who is not signed in to sign in" do
    get mountain_path(race)

    expect(response).to redirect_to(new_voter_session_path)
  end

  it "opens the signed-in voter's own mountain" do
    sign_in voter

    get mountain_path(race)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Voter: Priya Raman")
  end

  it "refuses another voter's mountain and their ratings" do
    sign_in voter

    get mountain_path(race, voter_id: neighbor.id)
    expect(response).to redirect_to(root_path)

    patch mountain_path(race), params: { voter_id: neighbor.id, ratings: { candidacy.id => "400" } }
    patch primary_candidates_mountain_path(race), params: { voter_id: neighbor.id, included: "1" }

    expect(Rating.where(voter: neighbor)).to be_empty
    expect(VoterRacePreference.where(voter: neighbor)).to be_empty
  end

  it "lets an admin open another voter's mountain" do
    sign_in admin

    get mountain_path(race, voter_id: neighbor.id)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Voter: Tomas Lind")
  end

  it "keeps simulated data to admins" do
    sign_in voter

    expect { post simulate_mountain_path(race) }.not_to change(Candidacy, :count)
    expect(response).to redirect_to(root_path)

    get mountains_path
    expect(response.body).not_to include("Simulate Data")

    sign_in admin
    get mountains_path
    expect(response.body).to include("Simulate Data")
  end
end
