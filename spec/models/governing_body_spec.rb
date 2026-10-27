require "rails_helper"

RSpec.describe GoverningBody, type: :model do
  it "allows a board to exist without a branch" do
    board = create(:school_district_board)

    expect(board.branch).to be_nil
    expect(board.governance_type.name).to eq("Board")
  end

  it "keeps a court in the judicial branch" do
    court = create(:supreme_court)

    expect(court).to be_judicial
    expect(court.governance_type.name).to eq("Court")
  end

  it "shares one legislature type across levels and keeps houses as chambers" do
    legislature_type = create(:governance_type)
    congress = create(:federal_congress, governance_type: legislature_type)
    legislature = create(:state_legislature_body, governance_type: legislature_type)
    create(:chamber, governing_body: legislature, name: "Senate")
    create(:chamber, :assembly, governing_body: legislature)

    expect(congress.governance_type).to eq(legislature.governance_type)
    expect(legislature.chambers.map(&:name)).to contain_exactly("Senate", "Assembly")
  end
end
