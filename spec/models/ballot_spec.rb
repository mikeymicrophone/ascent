require "rails_helper"

# My ballot gathers the open real races where a voter lives, from the ward up to the country, plus the
# districts recorded for their residence, and shows how far they have got on each.
RSpec.describe Ballot do
  include_context "Port Merritt ballot"

  let!(:mayor) { create_race_for(office_in(port_merritt, "Mayor")) }
  let!(:ward_council) { create_race_for(office_in(ward_4, "City Council, Ward 4")) }
  let!(:sheriff) { create_race_for(office_in(alder_county, "Sheriff")) }
  let!(:governor) { create_race_for(office_in(state, "Governor")) }
  let!(:assembly) { create_race_for(office_in(assembly_52, "State Assembly")) }
  let!(:house) { create_race_for(office_in(congressional_7, "U.S. House")) }
  let!(:next_door) { create_race_for(office_in(ward_2, "City Council, Ward 2")) }
  let!(:finished) { create_race_for(office_in(port_merritt, "Port Commissioner"), :completed) }

  let(:ballot) { voter.ballot }

  it "lists the open races of every jurisdiction the residence sits in, and none from next door" do
    expect(ballot.races).to contain_exactly(mayor, ward_council, sheriff, governor, assembly, house)
  end

  it "groups them from city to federal, putting a congressional district under federal" do
    levels = ballot.levels.to_h { |level, mountains| [ level, mountains.map(&:race) ] }

    expect(levels.keys).to eq(%w[city county state federal])
    expect(levels).to include("city" => contain_exactly(mayor, ward_council), "county" => [ sheriff ],
                              "state" => contain_exactly(governor, assembly), "federal" => [ house ])
  end

  it "counts saved, started and untouched races" do
    candidates = create_list(:candidacy, 2, race: mayor)
    Mountain.new(voter: voter, race: mayor).publish!(ratings: { candidates.first.id => 410, candidates.last.id => 120 }, baseline: 280)
    Mountain.new(voter: voter, race: sheriff).revise_draft!(ratings: { create(:candidacy, race: sheriff).id => 300 })

    expect(ballot.progress_counts).to eq("saved" => 1, "started" => 1, "not_started" => 4)
  end

  it "offers next door and other places as pretend votes, but never the voter's own races" do
    expect(ballot.neighboring_races).to eq([ next_door ])
    expect(ballot.pretend_races("Port Merritt")).to eq([ next_door ])
  end

  it "counts a mountain with residents only where the voter lives" do
    expect(voter.resident_of?(house)).to be(true)
    expect(voter.resident_of?(next_door)).to be(false)
    expect(house.mode_for(voter)).to eq("ballot")
    expect(next_door.mode_for(voter)).to eq("pretend")
  end
end
