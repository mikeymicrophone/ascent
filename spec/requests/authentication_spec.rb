require "rails_helper"

RSpec.describe "Account access", type: :request do
  before { ActionMailer::Base.deliveries.clear }

  def page
    Nokogiri::HTML(response.body)
  end

  it "uses the same account layout for signup, login, recovery, and confirmation" do
    [ new_voter_registration_path, new_voter_session_path, new_voter_password_path, new_voter_confirmation_path ].each do |path|
      get path
      expect(response).to have_http_status(:ok)
      expect(page.at_css(".auth-shell h1")).to be_present
      expect(page.at_css(".auth-family").text).to eq("MICharisma")
      expect(page.at_css(".main-navigation")).to be_nil
      expect(page.at_css("body")["data-butterfly-enabled-value"]).to eq("false")
    end
  end

  it "posts Google sign-in separately from the email form without Turbo" do
    get new_voter_registration_path
    google = page.at_css("form[action='#{voter_google_oauth2_omniauth_authorize_path}']")
    expect(google["method"]).to eq("post")
    expect(google["data-turbo"]).to eq("false")
    expect(google.css("button").text).to include("Continue with Google")
    expect(google.ancestors("form")).to be_empty
    expect(page.at_css("input[autocomplete='given-name']")).to be_present
    expect(page.at_css("input[autocomplete='new-password']")).to be_present
  end

  it "hides Google when no OAuth client is configured" do
    allow(Voter).to receive(:google_sign_in_available?).and_return(false)
    get new_voter_session_path
    expect(page.at_css(".auth-google")).to be_nil
    expect(page.at_css(".auth-divider")).to be_nil
    expect(page.at_css("form.auth-form")).to be_present
  end

  it "keeps account settings in the application layout" do
    sign_in create(:voter)
    get edit_voter_registration_path
    expect(response).to have_http_status(:ok)
    expect(page.at_css("body.auth-page")).to be_nil
    expect(page.at_css("body")["data-butterfly-enabled-value"]).to eq("true")
  end

  it "creates an email account and sends confirmation instructions" do
    expect do
      post voter_registration_path, params: { voter: {
        first_name: "Rosa", last_name: "Delgado", email: "rosa.delgado@example.com",
        password: "long-enough-password", password_confirmation: "long-enough-password"
      } }
    end.to change(Voter, :count).by(1)
    expect(response).to have_http_status(:redirect)
    expect(Voter.find_by!(email: "rosa.delgado@example.com")).not_to be_confirmed
    expect(ActionMailer::Base.deliveries.one?).to be(true)
    expect(ActionMailer::Base.deliveries.last.to).to eq([ "rosa.delgado@example.com" ])
  end

  it "keeps invalid signup values and identifies field errors without returning passwords" do
    post voter_registration_path, params: { voter: {
      first_name: "", last_name: "Delgado", email: "rosa.delgado@example.com",
      password: "long-enough-password", password_confirmation: "different-password"
    } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(page.at_css("[role='alert']").text).to include("First name")
    expect(page.at_css("#voter_first_name")["aria-invalid"]).to eq("true")
    expect(page.at_css("#voter_first_name")["aria-describedby"]).to include("voter_first_name_error")
    expect(page.at_css("#voter_email")["value"]).to eq("rosa.delgado@example.com")
    expect(page.css("input[type='password']").all? { |input| input["value"].blank? }).to be(true)
  end

  it "signs in a confirmed voter with email and password" do
    voter = create(:voter, password: "long-enough-password", password_confirmation: "long-enough-password")
    post voter_session_path, params: { voter: { email: voter.email, password: "long-enough-password" } }
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Hello, #{voter.first_name}")
  end

  it "sends a password-reset email from the styled recovery form" do
    voter = create(:voter)
    post voter_password_path, params: { voter: { email: voter.email } }
    expect(response).to redirect_to(new_voter_session_path)
    expect(voter.reload.reset_password_token).to be_present
    expect(ActionMailer::Base.deliveries.one?).to be(true)
    follow_redirect!
    expect(page.at_css(".auth-shell h1").text).to eq("Log in")
    expect(page.at_css("[role='status']")).to be_present
  end

  it "renders token errors in the shared layout and completes a valid password reset" do
    voter = create(:voter)
    token, digest = Devise.token_generator.generate(Voter, :reset_password_token)
    voter.update!(reset_password_token: digest, reset_password_sent_at: Time.current)
    get edit_voter_password_path(reset_password_token: token)
    expect(page.at_css(".auth-shell h1").text).to eq("Change your password")
    expect(page.at_css("#voter_reset_password_token")["value"]).to eq(token)
    put voter_password_path, params: { voter: {
      reset_password_token: token, password: "replacement-password", password_confirmation: "does-not-match"
    } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(page.at_css(".auth-errors")).to be_present
    put voter_password_path, params: { voter: {
      reset_password_token: token, password: "replacement-password", password_confirmation: "replacement-password"
    } }
    expect(response).to have_http_status(:redirect)
    expect(voter.reload.valid_password?("replacement-password")).to be(true)
    expect(voter.reset_password_token).to be_nil
  end
end
