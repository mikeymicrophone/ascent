require "rails_helper"

# Seed data and TIGER/Line spell the same legislative district differently; both reduce to one key.
RSpec.describe Seeds::DistrictLabel do
  {
    "State House District: Thirty-Fifth Middlesex" => "35th Middlesex District",
    "State Senate District: Cape & Islands" => "Cape and Islands District",
    "State Senate District: Berkshire, Hampden, Franklin & Hampshire" => "Berkshire-Hampden-Franklin-Hampshire District",
    "Assembly District 7" => "Assembly District 007",
    "State House District Chittenden-13" => "Chittenden-13 State House District",
    "House of Delegates District 29A" => "State Legislative Subdistrict 29A"
  }.each do |seed_name, tiger_name|
    it "reads #{seed_name.inspect} and #{tiger_name.inspect} alike" do
      expect(described_class.key(seed_name)).to eq(described_class.key(tiger_name))
    end
  end

  it "keeps districts with different numbers apart" do
    expect(described_class.key("First Essex")).not_to eq(described_class.key("Eleventh Essex"))
  end
end
