require 'rails_helper'

# Ratings and baselines reveal how one voter judges candidates, so only that voter, or an admin, may see them.
RSpec.describe "Voter preference privacy", type: :request do
  let(:voter) { create(:voter) }
  let(:neighbor) { create(:voter) }
  let(:candidacy) { create(:candidacy) }
  let!(:rating) { Rating.create!(voter: voter, candidacy: candidacy, rating: 320) }
  let!(:baseline) { VoterRaceBaseline.create!(voter: voter, race: candidacy.race, baseline: 250) }

  it "shows a voter their own rating and baseline" do
    sign_in voter

    get rating_path(rating)
    expect(response).to have_http_status(:ok)
    get voter_race_baseline_path(baseline)
    expect(response).to have_http_status(:ok)
  end

  it "hides them from other voters, and every voter's list from all but admins" do
    sign_in neighbor

    [ rating_path(rating), voter_race_baseline_path(baseline), ratings_path, voter_race_baselines_path ].each do |path|
      get path
      expect(response).to redirect_to(root_path), path
    end

    sign_in create(:voter, admin: true)
    get ratings_path
    expect(response).to have_http_status(:ok)
  end
end
