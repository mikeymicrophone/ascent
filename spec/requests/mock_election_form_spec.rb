require "rails_helper"

RSpec.describe "Mock election form", type: :request do
  include_context "Port Merritt ballot"

  it "offers the places where the voter lives" do
    sign_in voter

    get new_mock_election_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Make a mock election", "Port Merritt Ward 4", "Candidates, one per line")
  end
end
