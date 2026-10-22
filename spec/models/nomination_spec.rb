require 'rails_helper'

# A primary is a race for a nomination: an Office whose position is Nominee, naming the office it
# nominates for and the organization that nominates. Everyone who ran in a primary can then stand in
# a simulated general, where approval voting may favor a candidate who lost the primary.
RSpec.describe "Nominations", type: :model do
  let(:georgia) { create(:state, name: "Georgia", code: "GA") }
  let(:jurisdiction) { create(:jurisdiction, jurisdictionable: georgia) }
  let(:year) { create(:year, year: 2026) }
  let(:governor) { create(:office, position: create(:position, :executive, title: "Governor"), jurisdiction: jurisdiction) }
  let(:nominee) { Position.create!(title: Position::NOMINEE_TITLE, branch: :executive) }
  let(:democrats) { Party.create!(name: "Democratic Party", state: georgia) }
  let(:republicans) { Party.create!(name: "Republican Party", state: georgia) }

  def nomination(organization, count: 1)
    Office.create!(position: nominee, jurisdiction: jurisdiction, nominee_for: governor, nominating_organization: organization, nominee_count: count, is_active: true)
  end

  def race_in(kind, office, date)
    election = Election.find_or_create_by!(jurisdiction: jurisdiction, year: year, kind: kind) do |record|
      record.name = "Georgia #{kind.humanize} Election 2026"
      record.election_date = date
      record.status = "upcoming"
      record.is_mock = false
      record.is_historical = false
    end
    Race.create!(election: election, office: office, status: "upcoming")
  end

  def candidacy(race, given, surname)
    Candidacy.create!(race: race, person: create(:person, first_name: given, middle_name: nil, last_name: surname), status: "active")
  end

  it "names the organization and the office it nominates for" do
    expect(nomination(democrats).name).to eq("Democratic Party nominee for Governor - Georgia")
  end

  it "gathers every primary candidate into the general's field once" do
    general = race_in("general", governor, Date.new(2026, 11, 3))
    democratic_primary = race_in("primary", nomination(democrats), Date.new(2026, 5, 19))
    republican_primary = race_in("primary", nomination(republicans), Date.new(2026, 5, 19))
    marisol = candidacy(democratic_primary, "Marisol", "Okafor")
    candidacy(democratic_primary, "Dwayne", "Pritchett")
    candidacy(republican_primary, "Harlan", "Voss")
    general_okafor = Candidacy.create!(race: general, person: marisol.person, status: "active")
    general_voss = Candidacy.create!(race: general, person: Person.find_by!(last_name: "Voss"), status: "active")

    field = general.field_with_primary_candidates

    expect(field.first(2)).to eq([ general_okafor, general_voss ])
    expect(field.map { it.person.last_name }).to contain_exactly("Okafor", "Voss", "Pritchett")
    expect(general.nomination_races).to contain_exactly(democratic_primary, republican_primary)
  end

  it "lets a top-two primary nominate two through a placeholder organization" do
    top_two = Organization.create!(name: "Georgia Top-Two Primary", kind: "nonpartisan_primary", state: georgia)

    expect(nomination(top_two, count: 2)).to have_attributes(nominee_count: 2, nominating_organization: top_two)
  end

  it "requires a nomination to name its office, organization, and count, under the Nominee position" do
    office = Office.new(position: governor.position, jurisdiction: jurisdiction, nominee_for: governor, is_active: true)

    expect(office).not_to be_valid
    expect(office.errors.messages).to include(
      nominating_organization: [ "is required for a nomination" ],
      nominee_count: [ "is required for a nomination" ],
      position: [ "must be Nominee for a nomination" ]
    )
  end

  it "keeps a nomination in the nominated office's jurisdiction" do
    elsewhere = create(:jurisdiction)
    office = Office.new(position: nominee, jurisdiction: elsewhere, nominee_for: governor, nominating_organization: democrats, nominee_count: 1, is_active: true)

    expect(office).not_to be_valid
    expect(office.errors[:jurisdiction]).to include("must be the nominated office's")
  end

  it "keeps parties as organizations with a state and no kind" do
    expect(democrats).to be_a(Organization)
    expect(Organization.find(democrats.id)).to be_a(Party)
    expect(Party.new(name: "Green Party", state: georgia, kind: "advocacy")).not_to be_valid
    expect(Organization.new(name: "Georgia AFL-CIO", kind: "union", state: georgia)).to be_valid
  end
end
