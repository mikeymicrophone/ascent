# The sample ballot from the voting flow redesign: a voter in Ward 4 of the City of Port Merritt, in
# Alder County, who also sits in Assembly District 52 and Congressional District 7. Every name here is
# invented. Ward 2 is next door, so its races are a pretend vote away.
RSpec.shared_context "Port Merritt ballot" do
  let(:united_states) { create(:jurisdiction, jurisdictionable: create(:country, name: "United States")) }
  let(:state) { create(:jurisdiction, jurisdictionable: create(:state, name: "Calder", country: united_states.jurisdictionable), parent: united_states) }
  let(:alder_county) { create(:jurisdiction, jurisdictionable: create(:county, name: "Alder County", state: state.jurisdictionable), parent: state) }
  let(:port_merritt) do
    create(:jurisdiction, parent: alder_county,
      jurisdictionable: create(:municipality, name: "Port Merritt", state: state.jurisdictionable, county: alder_county.jurisdictionable))
  end
  let(:ward_4) { create(:jurisdiction, jurisdictionable: create(:district, name: "Port Merritt Ward 4", kind: "ward"), parent: port_merritt) }
  let(:ward_2) { create(:jurisdiction, jurisdictionable: create(:district, name: "Port Merritt Ward 2", kind: "ward"), parent: port_merritt) }
  let(:assembly_52) { create(:jurisdiction, jurisdictionable: create(:district, name: "Assembly District 52", kind: "assembly district"), parent: state) }
  let(:congressional_7) { create(:jurisdiction, jurisdictionable: create(:district, name: "Congressional District 7", kind: "congressional district"), parent: state) }

  let(:voter) { create(:voter, first_name: "Rosa", last_name: "Delgado") }
  let!(:residence) do
    create(:residence, voter: voter, jurisdiction: ward_4, congressional_district: congressional_7, state_house_district: assembly_52,
      notes: "Lives on Harbor Street, Ward 4")
  end

  def office_in(jurisdiction, title)
    create(:office, position: create(:position, title: title), jurisdiction: jurisdiction)
  end
end
