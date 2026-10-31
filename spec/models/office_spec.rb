require "rails_helper"

RSpec.describe Office, type: :model do
  it "uses the governing body's branch when the office sits in one" do
    office = create(:office, :judicial, governing_body: create(:state_legislature_body))

    expect(office.branch).to eq("legislative")
  end

  it "uses the position branch when the office has no body" do
    office = create(:judicial_office)

    expect(office.branch).to eq("judicial")
  end

  it "assigns the chamber's governing body when only the chamber is set" do
    chamber = create(:chamber)
    office = create(:office, chamber: chamber)

    expect(office.governing_body).to eq(chamber.governing_body)
  end

  it "rejects a chamber from a different governing body" do
    office = build(:office, governing_body: create(:city_council), chamber: create(:chamber))

    expect(office).not_to be_valid
    expect(office.errors[:chamber]).to include("must belong to the governing body")
  end

  describe "#name" do
    let(:new_york) { create(:state, name: "New York") }
    let(:new_york_jurisdiction) { create(:jurisdiction, jurisdictionable: new_york) }

    def office(title, place, parent: nil, branch: :executive)
      create(:office, position: create(:position, title: title, branch: branch), jurisdiction: create(:jurisdiction, jurisdictionable: place, parent: parent))
    end

    def district_office(title, name, kind)
      office(title, create(:district, name: name, kind: kind), parent: new_york_jurisdiction)
    end

    it "names the place a town, county, or state office serves" do
      expect(office("Mayor", create(:municipality, name: "Albany", state: new_york)).name).to eq("Mayor of Albany")
      expect(office("County Executive", create(:county, name: "Putnam County", state: new_york)).name).to eq("County Executive of Putnam County")
      expect(office("Governor", new_york).name).to eq("Governor of New York")
    end

    it "gives the United States and the District of Columbia their article" do
      expect(office("President", create(:country, name: "United States")).name).to eq("President of the United States")
      expect(office("Mayor", create(:state, name: "District of Columbia")).name).to eq("Mayor of the District of Columbia")
    end

    it "names a legislator elected statewide as coming from the state" do
      expect(office("Senator", create(:state, name: "Texas"), branch: :legislative).name).to eq("Senator from Texas")
    end

    # A district's own name repeats its state and kind: "New York State Senate District 21".
    it "names a district office by its state and what sets the district apart" do
      expect(district_office("State Senator", "New York State Senate District 21", "state senate district").name)
        .to eq("State Senator in New York, District 21")
      expect(district_office("Justice", "New York Judicial District 9", "judicial district").name).to eq("Justice in New York, District 9")
      expect(district_office("Circuit Judge", "New York Circuit 11", "judicial circuit").name).to eq("Circuit Judge in New York, Circuit 11")
      expect(district_office("State Representative", "New York State House District: Twenty-Third Middlesex", "state house district").name)
        .to eq("State Representative in New York, Twenty-Third Middlesex")
      expect(district_office("Judge of Probate", "New York Judge of Probate (Bethel, Redding)", "judge of probate district").name)
        .to eq("Judge of Probate in New York, Bethel, Redding")
      expect(district_office("Representative", "New York At-Large Congressional District", "congressional district").name)
        .to eq("Representative in New York, At-Large")
    end

    it "names a district outside any state by the district itself" do
      expect(office("Delegate", create(:district, name: "Guam Delegate District", kind: "congressional district")).name)
        .to eq("Delegate in Guam Delegate District")
    end
  end
end
