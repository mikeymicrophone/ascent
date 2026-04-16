require 'rails_helper'

RSpec.describe "Mountains", type: :request do
  describe "GET /mountains" do
    context "with no active elections" do
      let!(:completed_election) { create(:election, :completed) }

      it "renders the empty state" do
        get mountains_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Mountain Visualizations")
        expect(response.body).to include("No active elections are ready for the mountain interface.")
      end
    end

    context "with active elections" do
      let!(:country) { create(:country, name: "United States") }
      let!(:state) { create(:state, name: "Pennsylvania", country: country) }
      let!(:city) { create(:city, name: "Pittsburgh", state: state) }
      let!(:position) { create(:position, title: "Mayor") }
      let!(:office) { create(:office, position: position, jurisdiction: city) }
      let!(:year) { create(:year, year: 2026) }
      let!(:active_election) { create(:election, :active, office: office, year: year, description: "A live municipal demonstration.") }

      before do
        create_list(:candidacy, 2, election: active_election)
      end

      it "lists active elections with action links" do
        get mountains_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(active_election.name)
        expect(response.body).to include("Candidates: 2")
        expect(response.body).to include("Office: Mayor")
        expect(response.body).to include("View Mountain")
        expect(response.body).to include("Simulate Data")
      end
    end
  end

  describe "GET /mountains/:id" do
    let!(:election) { create(:election, :active) }

    it "renders the mountain page" do
      get mountain_path(election)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(election.name)
    end

    it "returns not found when the election does not exist" do
      get mountain_path(999_999)

      expect(response).to have_http_status(:not_found)
    end
  end
end
