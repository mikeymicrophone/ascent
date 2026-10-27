require "rails_helper"

# The Census geocoder answers with every match for an address; the first is the best one.
RSpec.describe CensusGeocoder do
  let(:matched) do
    { result: { addressMatches: [
      { coordinates: { x: -77.035189, y: 38.898702 }, matchedAddress: "1600 PENNSYLVANIA AVE NW, WASHINGTON, DC, 20500" }
    ] } }.to_json
  end

  it "returns the point and the address as the Census matched it" do
    allow(described_class).to receive(:fetch).with("1600 Pennsylvania Ave NW, Washington, DC").and_return(matched)

    expect(described_class.locate("  1600 Pennsylvania Ave NW,  Washington, DC ")).to eq(
      described_class::Match.new(latitude: 38.898702, longitude: -77.035189, matched_address: "1600 PENNSYLVANIA AVE NW, WASHINGTON, DC, 20500"))
  end

  it "returns nothing when the Census finds no match" do
    allow(described_class).to receive(:fetch).and_return({ result: { addressMatches: [] } }.to_json)

    expect(described_class.locate("99999 Nowhere Lane")).to be_nil
  end

  it "reports an answer it can't read as unavailable" do
    allow(described_class).to receive(:fetch).and_return("<html>Service Unavailable</html>")

    expect { described_class.locate("1 Main St") }.to raise_error(described_class::Unavailable)
  end

  it "reports a timeout as unavailable" do
    allow(Net::HTTP).to receive(:start).and_raise(Net::ReadTimeout)

    expect { described_class.locate("1 Main St") }.to raise_error(described_class::Unavailable)
  end
end
