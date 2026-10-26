require "rails_helper"

# My ballot lists the open races where a voter lives with how far they have got, then offers races
# elsewhere for a pretend vote.
RSpec.describe "My ballot", type: :request do
  include_context "Port Merritt ballot"

  let!(:mayor) { create_race_for(office_in(port_merritt, "Mayor")) }
  let!(:house) { create_race_for(office_in(congressional_7, "U.S. House")) }
  let!(:next_door) { create_race_for(office_in(ward_2, "City Council, Ward 2")) }

  it "sends a visitor who is not signed in to sign in" do
    get ballot_path

    expect(response).to redirect_to(new_voter_session_path)
  end

  it "groups the voter's races by level with where they stand on each" do
    candidates = create_list(:candidacy, 3, race: mayor)
    Mountain.new(voter: voter, race: mayor).publish!(ratings: { candidates.first.id => 410, candidates.second.id => 120 }, baseline: 280)
    sign_in voter

    get ballot_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Your ballot", "Port Merritt Ward 4", "Port Merritt · Congressional District 7 · Assembly District 52")
    expect(response.body).to include("City", "Federal", "You approve 1 of 3", "Open mountain", "Start rating")
    expect(response.body).to include(edit_mountain_path(house), race_results_path(mayor))
    # Next door is a pretend vote, offered below the ballot rather than on it.
    expect(response.body.split('id="elsewhere"').first).not_to include("City Council, Ward 2")
  end

  it "finds races elsewhere for a pretend vote" do
    sign_in voter

    get ballot_path(q: "Ward 2")

    expect(response.body).to include("Pretend vote anywhere", "City Council, Ward 2", edit_mountain_path(next_door))
  end

  it "explains a missing residence and still offers pretend votes" do
    sign_in create(:voter, first_name: "Omar", last_name: "Haddad")

    get ballot_path

    expect(response.body).to include("We don&#39;t know where you vote yet", "Pretend vote anywhere")
  end
end
