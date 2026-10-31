require "rails_helper"

RSpec.describe "Analytics events", type: :request do
  let(:voter) { create(:voter, first_name: "Rosa", last_name: "Delgado") }
  let(:race) { create(:race, :active) }
  let!(:candidate) { create(:candidacy, race: race) }

  def events(name)
    Ahoy::Event.where(name: name).order(:id)
  end

  def register
    post voter_registration_path, params: { voter: {
      first_name: "Eli", last_name: "Brooks", email: "eli.brooks@example.com",
      password: "long-enough-password", password_confirmation: "long-enough-password"
    } }
  end

  it "exposes page context and accepts browser events on the original anonymous visit" do
    get race_path(race)
    page = Nokogiri::HTML(response.body)
    context = JSON.parse(page.at_css('meta[name="ascent-analytics"]')["content"])
    expect(context).to include("page_type" => "races.show", "record_id" => race.id.to_s, "enabled" => true)
    visit = Ahoy::Visit.sole

    post "/ahoy/events", params: { visit_token: cookies["ahoy_visit"], visitor_token: cookies["ahoy_visitor"],
      events: [ { name: "page_viewed", properties: context.except("enabled") } ] }, as: :json

    expect(response).to have_http_status(:ok)
    expect(events("page_viewed").sole.visit).to eq(visit)
    expect(Ahoy::Visit.count).to eq(1)
  end

  it "keeps drafts out of save conversions and records matching attempt and success events" do
    sign_in voter
    patch draft_mountain_path(race), params: { ratings: { candidate.id => 360 }, baseline: 280 }, as: :json
    expect(events("mountain_save")).to be_empty

    post save_mountain_path(race), as: :json

    expect(response).to have_http_status(:ok)
    attempt, success = events("mountain_save").map(&:properties)
    expect(attempt).to include("outcome" => "attempted", "first_save" => true, "rated_count" => 1,
      "candidate_count" => 1, "race_id" => race.id, "race_mode" => "pretend")
    expect(success).to include("outcome" => "succeeded", "attempt_id" => attempt.fetch("attempt_id"))
    expect(success.fetch("seconds_since_first_edit")).to be >= 0

    patch draft_mountain_path(race), params: { ratings: { candidate.id => 400 } }, as: :json
    post save_mountain_path(race), as: :json
    expect(events("mountain_save").last.properties).to include("first_save" => false)
  end

  it "records failed saves without a success conversion" do
    sign_in voter
    mountain = Mountain.new(voter: voter, race: race)
    mountain.publish!(ratings: { candidate.id => 360 }, baseline: 200)
    5.times { |index| mountain.publish!(ratings: {}, baseline: 210 + index * 10) }
    patch draft_mountain_path(race), params: { baseline: 400 }, as: :json

    post save_mountain_path(race), as: :json

    expect(response).to have_http_status(:unprocessable_content)
    expect(events("mountain_save").map { it.properties["outcome"] }).to eq(%w[attempted failed])
  end

  it "distinguishes an explicitly discarded draft" do
    sign_in voter
    patch draft_mountain_path(race), params: { ratings: { candidate.id => 360 } }, as: :json
    delete draft_mountain_path(race), as: :json

    expect(events("mountain_save").sole.properties).to include("outcome" => "discarded")
  end

  it "records successful visibility transitions once, separately from saving" do
    sign_in voter
    Mountain.new(voter: voter, race: race).publish!(ratings: { candidate.id => 360 }, baseline: 200)
    allow_any_instance_of(MountainPreview).to receive(:png).and_return("mountain image")

    post share_mountain_path(race)
    post share_mountain_path(race)
    delete share_mountain_path(race)
    delete share_mountain_path(race)

    expect(events("mountain_visibility_changed").map { it.properties["visibility"] }).to eq(%w[public private])
  end

  it "does not report publication when the mountain has not been saved" do
    sign_in voter
    post share_mountain_path(race)

    expect(events("mountain_visibility_changed")).to be_empty
  end

  it "attributes invited email signups and their connections to the new voter" do
    referral = "a" * 32
    get invite_path(token: voter.invite_token, ref: referral)
    expect(events("invite_opened").sole.properties).to include("inviter_id" => voter.id, "already_signed_in" => false, "referral_id" => referral)
    expect(events("invite_opened").sole.properties.fetch("path")).to eq("/invite/:token")
    register

    signup = events("signup_completed").sole
    expect(signup.user.email).to eq("eli.brooks@example.com")
    expect(signup.properties).to include("method" => "email", "inviter_id" => voter.id, "referral_id" => referral, "landing_path" => "/invite/:token")
    expect(events("connection_created").sole.properties).to include("source" => "invited_signup", "inviter_id" => voter.id)
    expect(events("connection_created").sole.user).to eq(signup.user)
  end

  it "does not count a rejected registration" do
    post voter_registration_path, params: { voter: { first_name: "Eli", last_name: "Brooks" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(events("signup_completed")).to be_empty
    expect(events("connection_created")).to be_empty
  end

  it "counts a new Google signup once, but not a returning or linked account" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: "rosa-google-account",
      info: { email: "rosa.delgado@example.com", first_name: "Rosa", last_name: "Delgado", email_verified: true }
    )
    2.times do
      post voter_google_oauth2_omniauth_authorize_path
      follow_redirect!
      delete destroy_voter_session_path
    end

    expect(events("signup_completed").sole.properties).to include("method" => "google")
  ensure
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end

  it "does not count linking an existing email to Google as a signup" do
    voter
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: "rosa-google-account",
      info: { email: voter.email, first_name: "Rosa", last_name: "Delgado", email_verified: true }
    )
    post voter_google_oauth2_omniauth_authorize_path
    follow_redirect!

    expect(response).to redirect_to(root_path)
    expect(events("signup_completed")).to be_empty
  ensure
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
  end

  it "counts an existing voter's connection only when it is newly created" do
    influencer = create(:voter, public_influencer: true)
    influencer.invites.create!(invitee: create(:voter))
    sign_in voter
    2.times { post invites_path, params: { token: influencer.invite_token, source: "influencer" } }

    expect(events("connection_created").sole.properties).to include("source" => "influencer", "inviter_id" => influencer.id)
    expect(events("signup_completed")).to be_empty
  end

  it "excludes staff and browser opt-outs from visits and events" do
    sign_in create(:admin_voter)
    get root_path
    post "/ahoy/events", params: { visit_token: SecureRandom.uuid, visitor_token: SecureRandom.uuid,
      events: [ { name: "page_viewed", properties: {} } ] }, as: :json
    expect(response).to have_http_status(:ok)
    expect(events("page_viewed")).to be_empty
    expect(Ahoy::Visit.count).to eq(0)

    sign_out :voter
    cookies[:ascent_analytics_exclude] = "1"
    register
    expect(events("signup_completed")).to be_empty
    expect(Ahoy::Visit.count).to eq(0)
  end

  it "keeps shared-page attribution through browsing to signup" do
    get race_path(race, ref: "b" * 32)
    get approval_voting_path
    register

    expect(events("signup_completed").sole.properties).to include("referral_id" => "b" * 32)
  end

  it "identifies an individual public influencer page without recording its token in event paths" do
    influencer = create(:voter, public_influencer: true)
    influencer.invites.create!(invitee: voter)
    get influencer_path(token: influencer.invite_token)

    context = JSON.parse(Nokogiri::HTML(response.body).at_css('meta[name="ascent-analytics"]')["content"])
    expect(context).to include("record_id" => influencer.id.to_s, "page_type" => "influencers.show", "path" => "/influencers/:token")
  end

  it "ignores invalid referral identifiers and does not carry attribution into a new Ahoy visit" do
    get race_path(race, ref: "a" * 32)
    cookies.delete("ahoy_visit")
    get root_path(ref: "not-a-referral")
    register

    expect(events("signup_completed").sole.properties).not_to have_key("referral_id")
  end
end
