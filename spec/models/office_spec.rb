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
end
