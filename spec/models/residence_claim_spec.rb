require "rails_helper"

# A residence is a town plus its House, state senate and state assembly districts, with dates. A location
# finds the smallest town and each district by boundary and is then forgotten; a searched town fills in
# any district it sits wholly inside, and the voter picks the rest. Past residences take the same shape.
RSpec.describe ResidenceClaim do
  include_context "Port Merritt ballot"

  let(:factory) { RGeo::Geos.factory(srid: 4326) }
  let(:newcomer) { create(:voter, first_name: "Omar", last_name: "Haddad") }
  let(:senate_9) { create(:jurisdiction, jurisdictionable: create(:district, name: "Calder State Senate District 9", kind: "state senate district"), parent: state) }
  let(:assembly_53) { create(:jurisdiction, jurisdictionable: create(:district, name: "Calder Assembly District 53", kind: "assembly district"), parent: state) }

  def boundary!(jurisdiction, west, south, width, height = width)
    corners = [ [ west, south ], [ west + width, south ], [ west + width, south + height ], [ west, south + height ], [ west, south ] ]
    ring = factory.linear_ring(corners.map { factory.point(*it) })
    JurisdictionBoundary.create!(jurisdiction: jurisdiction, geometry: factory.multi_polygon([ factory.polygon(ring) ]), valid_from: Date.new(2024, 1, 1))
  end

  # Port Merritt spans -76..-75 by 42..43. Congressional District 7 covers all of it; the state senate
  # district covers all of it; the city is split between Assembly Districts 52 (west) and 53 (east).
  before do
    boundary!(state, -80, 40, 8)
    boundary!(alder_county, -77, 41, 3)
    boundary!(port_merritt, -76, 42, 1)
    boundary!(congressional_7, -78, 41, 3)
    boundary!(senate_9, -76.5, 41.5, 2)
    boundary!(assembly_52, -76.5, 41.5, 1, 2)
    boundary!(assembly_53, -75.5, 41.5, 1, 2)
  end

  describe "from a location" do
    it "finds the town and each chamber's district" do
      claim = described_class.new(latitude: 42.5, longitude: -75.2, voter: newcomer)

      expect(claim).to be_valid
      expect(claim.town).to eq(port_merritt)
      expect(claim.districts).to eq("congressional" => congressional_7, "state_senate" => senate_9, "state_house" => assembly_53)
    end

    it "prefers the smaller of two towns it falls in" do
      village = create(:jurisdiction, jurisdictionable: create(:municipality, name: "Merritt Landing", state: state.jurisdictionable), parent: alder_county)
      boundary!(village, -75.3, 42.4, 0.2)

      expect(described_class.new(latitude: 42.5, longitude: -75.2, voter: newcomer).town).to eq(village)
    end

    it "falls back to the county outside any town" do
      claim = described_class.new(latitude: 41.5, longitude: -76.8, voter: newcomer)

      expect(claim.town).to eq(alder_county)
      expect(claim.district("congressional")).to eq(congressional_7)
    end

    it "can't place a location outside every boundary" do
      claim = described_class.new(latitude: 10, longitude: 10, voter: newcomer)

      expect(claim).not_to be_valid
      expect(claim.errors.full_messages).to include(/couldn't place that location/)
    end
  end

  describe "from a searched town" do
    let(:claim) { described_class.new(jurisdiction_id: port_merritt.id, voter: newcomer) }

    it "fills in the districts the town sits wholly inside" do
      expect(claim.district("congressional")).to eq(congressional_7)
      expect(claim.district("state_senate")).to eq(senate_9)
    end

    it "asks the voter to pick where the town is split, and takes the pick" do
      expect(claim.needs_pick?("state_house")).to be(true)
      expect(claim.district_choices("state_house")).to contain_exactly(assembly_52, assembly_53)

      picked = described_class.new(jurisdiction_id: port_merritt.id, state_house_district_id: assembly_52.id, voter: newcomer)
      expect(picked.district("state_house")).to eq(assembly_52)
    end

    it "offers the state's districts when the town's boundary isn't mapped" do
      unmapped = create(:jurisdiction, jurisdictionable: create(:municipality, name: "Halden Bay", state: state.jurisdictionable), parent: alder_county)
      claim = described_class.new(jurisdiction_id: unmapped.id, voter: newcomer)

      expect(claim.district_choices("state_house")).to contain_exactly(assembly_52, assembly_53)
      expect(claim.district("state_house")).to be_nil
    end
  end

  it "saves a new current residence, ending the old one today and re-sorting saved mountains" do
    mayor = create_race_for(office_in(port_merritt, "Mayor"))
    candidacy = create(:candidacy, race: mayor)
    Mountain.new(voter: voter, race: mayor).publish!(ratings: { candidacy.id => 300 }, baseline: 200)
    halden_bay = create(:jurisdiction, jurisdictionable: create(:municipality, name: "Halden Bay", state: state.jurisdictionable), parent: alder_county)

    residence = described_class.new(jurisdiction_id: halden_bay.id, congressional_district_id: congressional_7.id, voter: voter).save!

    expect(residence).to have_attributes(jurisdiction: halden_bay, congressional_district: congressional_7, status: "active", ended_on: nil)
    expect(voter.residences.past.sole).to have_attributes(jurisdiction: ward_4, ended_on: Date.current)
    expect(VoterRaceBaseline.find_by!(voter: voter)).to be_visitor
  end

  it "adds a second current residence when the voter lives here as well, keeping the first" do
    halden_bay = create(:jurisdiction, jurisdictionable: create(:municipality, name: "Halden Bay", state: state.jurisdictionable), parent: alder_county)

    added = described_class.new(jurisdiction_id: halden_bay.id, moving: false, voter: voter).save!

    expect(voter.current_residences).to contain_exactly(residence, added)
    expect(residence.reload.ended_on).to be_nil
  end

  it "adds a past residence in the same shape, leaving the current one alone" do
    claim = described_class.new(jurisdiction_id: port_merritt.id, state_house_district_id: assembly_53.id, past: true,
      started_on: Date.new(2015, 6, 1), ended_on: Date.new(2019, 8, 31), voter: voter)

    past = claim.save!

    expect(past).to have_attributes(started_on: Date.new(2015, 6, 1), ended_on: Date.new(2019, 8, 31), state_house_district: assembly_53,
      congressional_district: congressional_7)
    expect(voter.current_residence).to eq(residence)
    expect(voter.residences.lived_in_between(Date.new(2018, 1, 1), Date.new(2018, 12, 31))).to eq([ past ])
  end

  it "needs both dates for a past residence, in order" do
    claim = described_class.new(jurisdiction_id: port_merritt.id, past: true, started_on: Date.new(2020, 1, 1), ended_on: Date.new(2019, 1, 1), voter: voter)

    expect(claim).not_to be_valid
    expect(claim.errors[:ended_on]).to include("must be on or after the date you moved in")
  end
end
