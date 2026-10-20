require 'rails_helper'

RSpec.describe "Mountains", type: :request do
  describe "GET /mountains" do
    context "with no active races" do
      let!(:completed_race) { create(:race, :completed) }

      it "renders the empty state" do
        get mountains_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Mountain Visualizations")
        expect(response.body).to include("No active races are ready for the mountain interface.")
      end
    end

    context "with active races" do
      let!(:country) { create(:country, name: "United States") }
      let!(:state) { create(:state, name: "Pennsylvania", country: country) }
      let!(:city) { create(:municipality, :with_jurisdiction, name: "Pittsburgh", state: state) }
      let!(:position) { create(:position, title: "Mayor") }
      let!(:office) { create(:office, position: position, jurisdiction: city.jurisdiction) }
      let!(:year) { create(:year, year: 2026) }
      let!(:active_race) { create_race_for(office, :active, year: year, description: "A live municipal demonstration.") }

      before do
        create_list(:candidacy, 2, race: active_race)
      end

      it "lists active races with action links" do
        get mountains_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(active_race.name)
        expect(response.body).to include("Election: #{active_race.election.name}")
        expect(response.body).to include("Candidates: 2")
        expect(response.body).to include("Office: Mayor")
        expect(response.body).to include("View Mountain")
        expect(response.body).to include("Simulate Data")
      end
    end
  end

  describe "GET /mountains/:id" do
    let!(:race) { create(:race, :active) }
    let!(:voter) { create(:voter) }

    it "renders the mountain page" do
      get mountain_path(race, voter_id: voter.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(race.name)
    end

    it "returns not found when the race does not exist" do
      get mountain_path(999_999)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /mountains/:id/edit" do
    let!(:race) { create(:race, :active) }
    let!(:voter) { create(:voter) }
    let!(:candidacy) { create(:candidacy, :active, race: race) }

    it "renders the editable mountain with the stimulus controller" do
      get edit_mountain_path(race, voter_id: voter.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(race.name)
      expect(response.body).to include('data-controller="mountain-editor"')
      expect(response.body).to include("rating-input-#{candidacy.id}")
      expect(response.body).to include("Save Changes")
    end
  end

  describe "GET /mountains/:id remains editable after viewing" do
    let!(:race) { create(:race, :active) }
    let!(:voter) { create(:voter) }
    let!(:candidacy) { create(:candidacy, :active, race: race) }
    let!(:rating) { create(:rating, voter: voter, candidacy: candidacy, rating: 300) }

    it "keeps the mountain-editor controller on the show page" do
      get mountain_path(race, voter_id: voter.id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-controller="mountain-editor"')
      expect(response.body).to include("mountain-chart editable")
      expect(response.body).to include("Save Changes")
      expect(response.body).to include("Rating: 300")
    end
  end

  describe "PATCH /mountains/:id" do
    let!(:race) { create(:race, :active) }
    let!(:voter) { create(:voter) }
    let!(:candidacy_a) { create(:candidacy, :active, race: race) }
    let!(:candidacy_b) { create(:candidacy, :active, race: race) }
    let!(:existing_rating) do
      create(:rating, voter: voter, candidacy: candidacy_a, rating: 100)
    end

    it "creates, updates, and removes ratings and baseline" do
      patch mountain_path(race, voter_id: voter.id), params: {
        baseline: 275,
        ratings: {
          candidacy_a.id => 420,
          candidacy_b.id => 180
        }
      }

      expect(response).to redirect_to(mountain_path(race, voter_id: voter.id))
      expect(flash[:notice]).to eq("Mountain ratings updated.")

      expect(existing_rating.reload.rating).to eq(420)
      expect(Rating.find_by(voter: voter, candidacy: candidacy_b).rating).to eq(180)
      expect(VoterRaceBaseline.find_by(voter: voter, race: race).baseline).to eq(275)

      follow_redirect!
      # After save, mountain must still be editable (not a read-only show page).
      expect(response.body).to include('data-controller="mountain-editor"')
      expect(response.body).to include("mountain-chart editable")
      expect(response.body).to include("Save Changes")
      expect(response.body).to include("Rating: 420")
      expect(response.body).to include("Rating: 180")
      expect(response.body).to include("Current Baseline: 275")
    end

    it "clears a rating when submitted blank" do
      patch mountain_path(race, voter_id: voter.id), params: {
        baseline: 250,
        ratings: {
          candidacy_a.id => ""
        }
      }

      expect(response).to redirect_to(mountain_path(race, voter_id: voter.id))
      expect(Rating.find_by(voter: voter, candidacy: candidacy_a)).to be_nil
    end
  end
end
