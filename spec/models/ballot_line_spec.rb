require "rails_helper"

RSpec.describe BallotLine, type: :model do
  let(:candidacy) { create(:candidacy, party_label: nil) }
  let(:state) { create(:state) }
  let(:working_families) { Party.create!(state: state, name: "Working Families") }

  it "makes a party's line that party's endorsement of the candidacy" do
    line = candidacy.ballot_lines.create!(label: "Working Families", kind: "party", party: working_families)

    expect(line.endorsement).to have_attributes(kind: "ballot_line", endorser: working_families, candidacy: candidacy)
  end

  it "removes the line's endorsement when the party link is cleared, leaving other endorsements alone" do
    line = candidacy.ballot_lines.create!(label: "Working Families", kind: "party", party: working_families)
    public_endorsement = candidacy.endorsements.create!(endorser: working_families, kind: "public", strength: 4)

    line.update!(party: nil)

    expect(candidacy.endorsements.reload).to contain_exactly(public_endorsement)
  end

  it "keeps party links to party lines" do
    line = candidacy.ballot_lines.build(label: "Gulf War Veteran", kind: "designation", party: working_families)

    expect(line).not_to be_valid
    expect(line.errors[:party]).to be_present
  end

  it "records labels that are not parties without an endorsement" do
    line = candidacy.ballot_lines.create!(label: "Petitioning Candidate", kind: "petition")

    expect(line.endorsement).to be_nil
  end
end
