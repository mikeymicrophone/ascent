require "rails_helper"

# The elections list groups elections under their day, filters by tab, kind, place and where the voter
# lives, and marks a signed-in voter's own elections, their progress and the ones they follow.
RSpec.describe "Elections listing", type: :request do
  include_context "Port Merritt ballot"

  let(:election_day) { 9.days.from_now.to_date }
  let!(:city_election) { create(:election, jurisdiction: port_merritt, name: "Port Merritt General Election", election_date: election_day, status: "upcoming") }
  let!(:special) { create(:election, jurisdiction: ward_2, name: "Ward 2 Special Election", kind: "special", election_date: election_day, status: "upcoming") }
  let!(:elsewhere) do
    create(:election, jurisdiction: create(:jurisdiction, jurisdictionable: create(:municipality, name: "Halden Bay")), name: "Halden Bay General Election",
                      election_date: election_day + 7, status: "upcoming")
  end
  let!(:mayor) { create(:race, election: city_election, office: create(:office, position: create(:position, title: "Mayor"), jurisdiction: port_merritt)) }

  it "groups elections under their day with how many fall on it" do
    get elections_path

    expect(response.body).to include(election_day.strftime("%A, %B %-d, %Y"), "2 elections · in 9 days", "Halden Bay General Election")
  end

  it "filters by kind and by a search for a place" do
    get elections_path(kind: "special")

    expect(response.body).to include("Ward 2 Special Election")
    expect(response.body).not_to include("Halden Bay General Election")

    get elections_path(q: "Halden")

    expect(response.body).to include("Halden Bay General Election")
    expect(response.body).not_to include("Ward 2 Special Election")
  end

  it "pulls out the voter's own elections, marks them, and can show only those" do
    candidacy = create(:candidacy, race: mayor)
    Mountain.new(voter: voter, race: mayor).publish!(ratings: { candidacy.id => 300 }, baseline: 200)
    voter.engagements.create!(engageable: city_election, kind: "follow")
    sign_in voter

    get elections_path

    expect(response.body).to include("Where you live", "1 of 1 seat saved", "Your ballot", "1 of 1 saved", "Following")

    get elections_path(near: "1")

    expect(response.body).to include("Port Merritt General Election")
    expect(response.body).not_to include("Halden Bay General Election", "Ward 2 Special Election")
  end

  it "keeps mock elections in their own tab" do
    create(:election, :mock, jurisdiction: port_merritt, name: "Classroom Mock Election", status: "upcoming")

    get elections_path
    expect(response.body).not_to include("Classroom Mock Election")

    get elections_path(tab: "mock")
    expect(response.body).to include("Classroom Mock Election", "row-badge-mock")
  end
end
