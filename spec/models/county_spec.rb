require "rails_helper"

RSpec.describe County do
  it "keeps FIPS as five digits, including leading zeros" do
    county = create(:county, fips: "01001")
    expect(county.reload.fips).to eq("01001")
    expect(build(:county, fips: "1001")).not_to be_valid
    expect(build(:county, fips: "AL001")).not_to be_valid
    expect(build(:county, fips: "")).to be_valid
  end

  it "rejects mismatches from either the county or its jurisdiction" do
    county = create(:county, :with_jurisdiction, fips: "01001").reload
    jurisdiction = county.jurisdiction
    expect(jurisdiction.update(census_class: "G4020", census_geoid: "01003")).to be(false)
    jurisdiction.update!(census_class: "G4020", census_geoid: "01001")
    expect(county.update(fips: "01003")).to be(false)
    expect(county.errors[:fips]).to include("must match the jurisdiction's Census GEOID")
  end
end
