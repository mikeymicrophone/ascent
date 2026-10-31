require "rails_helper"

RSpec.describe "Visit tracking", type: :request do
  let(:voter) { create :voter, email: "first.time.caucusgoer@example.com" }

  def sign_in_through_the_form
    post voter_session_path, params: { voter: { email: voter.email, password: "password123" } }
  end

  it "records an anonymous visit with first-party cookies and a masked IP" do
    get new_voter_session_path, headers: { "REMOTE_ADDR" => "203.0.113.42" }

    visit = Ahoy::Visit.sole
    expect(visit.user).to be_nil
    expect(visit.landing_page).to include new_voter_session_path
    expect(visit.ip).to eq "203.0.113.0"
    expect(cookies["ahoy_visit"]).to eq visit.visit_token
    expect(cookies["ahoy_visitor"]).to eq visit.visitor_token
  end

  it "links the anonymous visit to the voter who signs in" do
    get new_voter_session_path
    sign_in_through_the_form

    expect(Ahoy::Visit.sole.user).to eq voter
  end

  it "keeps the visit but drops the voter when the account is deleted" do
    get new_voter_session_path
    sign_in_through_the_form
    voter.destroy!

    expect(Ahoy::Visit.sole.user_id).to be_nil
  end
end
