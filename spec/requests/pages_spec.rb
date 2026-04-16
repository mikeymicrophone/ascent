require 'rails_helper'

RSpec.describe "Pages", type: :request do
  describe "GET /" do
    it "renders the project overview" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ascent helps communities test richer ways to vote before changing the real world.")
      expect(response.body).to include("For Philanthropic Partners")
      expect(response.body).to include("Three ways Ascent turns election reform into something testable.")
    end

    it "shows active election previews when data exists" do
      election = create(:election, :active, description: "A model election for the landing page.")

      get root_path

      expect(response.body).to include(election.name)
      expect(response.body).to include("Open Mountain")
    end
  end

  describe "GET /supporters" do
    it "renders the philanthropic overview page" do
      get supporters_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ascent is building public-interest infrastructure for studying better ballots and clearer governance.")
      expect(response.body).to include("The value proposition is civic capacity, not party advantage.")
      expect(response.body).to include("What support could fund next")
    end
  end
end
