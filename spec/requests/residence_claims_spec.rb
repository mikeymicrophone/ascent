require "rails_helper"

# The pages a voter uses to set where they live: search or use a location, check what it puts on the
# ballot, then save it.
RSpec.describe "Residence claims", type: :request do
  include_context "Port Merritt ballot"

  let(:newcomer) { create(:voter, first_name: "Omar", last_name: "Haddad") }
  let!(:mayor) { create_race_for(office_in(port_merritt, "Mayor")) }

  before do
    factory = RGeo::Geos.factory(srid: 4326)
    ring = factory.linear_ring([ [ -76, 42 ], [ -75, 42 ], [ -75, 43 ], [ -76, 43 ], [ -76, 42 ] ].map { factory.point(*it) })
    JurisdictionBoundary.create!(jurisdiction: port_merritt, geometry: factory.multi_polygon([ factory.polygon(ring) ]), valid_from: Date.new(2024, 1, 1))
    sign_in newcomer
  end

  it "sends a visitor who is not signed in to sign in" do
    sign_out newcomer

    get new_residence_claim_path

    expect(response).to redirect_to(new_voter_session_path)
  end

  it "offers a location button and finds places by name" do
    get new_residence_claim_path(q: "Port Mer")

    expect(response.body).to include("Set your residence", "Use my location", 'data-controller="locate"', "Port Merritt", "I live here")
  end

  it "shows where a location falls and what it puts on the ballot before saving" do
    post preview_residence_claim_path, params: { latitude: "42.5", longitude: "-75.5" }

    expect(response.body).to include("Check this is right", "Port Merritt", "1", "city race", "Make this my residence")
    expect(Residence.where(voter: newcomer)).to be_empty
  end

  it "says when a location can't be placed" do
    post preview_residence_claim_path, params: { latitude: "10", longitude: "10" }

    expect(response.body).to include("We couldn&#39;t place that", "Search for your city or town")
  end

  it "saves the residence and returns to the ballot" do
    post residence_claim_path, params: { latitude: "42.5", longitude: "-75.5" }

    expect(response).to redirect_to(ballot_path)
    expect(flash[:notice]).to eq("You live in Port Merritt now. Your ballot shows its races.")
    expect(newcomer.current_residence.jurisdiction).to eq(port_merritt)
    follow_redirect!
    expect(response.body).to include("Mayor")
  end

  describe "for a voter who already lives somewhere" do
    before { newcomer.claim_residence!(alder_county) }

    it "asks whether they moved here or live here as well" do
      post preview_residence_claim_path, params: { jurisdiction_id: port_merritt.id }

      expect(response.body).to include("I moved here", "I also live here")
      expect(response.body).not_to include("Make this my residence")
    end

    it "keeps the other place when they live here as well" do
      post residence_claim_path, params: { jurisdiction_id: port_merritt.id, moving: "0" }

      expect(flash[:notice]).to start_with("You also live in Port Merritt now")
      expect(newcomer.current_residences.map(&:jurisdiction)).to contain_exactly(alder_county, port_merritt)
    end

    it "ends the other place when they moved here" do
      post residence_claim_path, params: { jurisdiction_id: port_merritt.id, moving: "1" }

      expect(newcomer.current_residences.map(&:jurisdiction)).to eq([ port_merritt ])
    end
  end
end
