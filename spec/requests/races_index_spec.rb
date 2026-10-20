require 'rails_helper'

RSpec.describe "Races Index", type: :request do
  let!(:country) { create(:country, name: "United States", code: "US") }
  let!(:state) { create(:state, :with_jurisdiction, name: "California", country: country) }
  let!(:city) { create(:municipality, :with_jurisdiction, name: "Los Angeles", state: state) }
  let!(:mayor_office) { create(:office, position: create(:position, title: "Mayor"), jurisdiction: city.jurisdiction) }
  let!(:governor_office) { create(:office, position: create(:position, title: "Governor"), jurisdiction: state.jurisdiction) }
  let!(:mayor_race) { create_race_for(mayor_office, :active) }
  let!(:governor_race) { create_race_for(governor_office, :upcoming) }
  let!(:candidacy) { create(:candidacy, race: mayor_race, person: create(:person, first_name: "Karen", middle_name: nil, last_name: "Bass")) }

  describe "GET /races" do
    it "lists races with their offices and candidates" do
      get races_path

      expect(response).to have_http_status(200)
      expect(response.body).to include("Mayor - Los Angeles")
      expect(response.body).to include("Governor - California")
    end
  end

  describe "GET /offices/:office_id/races" do
    it "renders races scoped to one office" do
      get office_races_path(mayor_office)

      expect(response).to have_http_status(200)
      expect(response.body).to include("Mayor - Los Angeles")
      expect(response.body).not_to include("Governor - California")
    end
  end

  describe "GET /elections/:election_id/races" do
    it "renders races scoped to one election" do
      get election_races_path(governor_race.election)

      expect(response).to have_http_status(200)
      expect(response.body).to include("Governor - California")
      expect(response.body).not_to include("Mayor - Los Angeles")
    end
  end

  describe "GET /races/:id" do
    it "shows the race with its election, office, and candidates" do
      get race_path(mayor_race)

      expect(response).to have_http_status(200)
      expect(response.body).to include(mayor_race.election.name)
      expect(response.body).to include("Karen Bass")
      expect(response.body).to include("Vote")
    end
  end
end
