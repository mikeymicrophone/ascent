require "rails_helper"

RSpec.describe Municipality, type: :model do
  include_context "Port Merritt ballot"

  # Harbor Ward is a borough of Port Merritt that shares its borders with Alder County; the city itself
  # sits under the state, since it spans more than one county.
  describe "a town inside a city" do
    let(:city) { create(:municipality, name: "Port Merritt City", state: state.jurisdictionable) }
    let(:city_jurisdiction) { create(:jurisdiction, jurisdictionable: city, parent: state) }
    let(:borough) do
      create(:municipality, name: "Harbor Ward", state: state.jurisdictionable, county: alder_county.jurisdictionable, parent_municipality: city)
    end

    before { create(:jurisdiction, jurisdictionable: borough, parent: city_jurisdiction) }

    it "lists the races of the city above it and of the county beside it" do
      mayor = create_race_for(office_in(city_jurisdiction, "Mayor"))
      county_judge = create_race_for(office_in(alder_county, "County Judge"))
      governor = create_race_for(office_in(state, "Governor"))

      expect(borough.open_races_above).to contain_exactly(mayor, county_judge, governor)
    end

    it "must be in the same state as its city" do
      elsewhere = create(:state, name: "Merrow", country: united_states.jurisdictionable)
      borough.parent_municipality = create(:municipality, name: "Merrow City", state: elsewhere)

      expect(borough).not_to be_valid
      expect(borough.errors[:parent_municipality]).to include("must belong to the same state")
    end
  end
end
