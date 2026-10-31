require "rails_helper"

RSpec.describe "Influencers", type: :request do
  let!(:public_influencer) { create(:voter, first_name: "Marisol", last_name: "Vega", public_influencer: true) }
  let!(:private_influencer) { create(:voter, first_name: "Elias", last_name: "Brooks") }
  let!(:invitee) { create(:voter, first_name: "Rosa", last_name: "Delgado") }

  before do
    public_influencer.invites.create!(invitee: invitee)
    private_influencer.invites.create!(invitee: invitee)
    private_influencer.invites.create!(invitee: create(:voter))
  end

  def page
    Nokogiri::HTML(response.body)
  end

  def public_path
    influencer_path(token: public_influencer.invite_token)
  end

  it "ranks influencers by connections and keeps private rows anonymous" do
    get invites_path

    expect(response).to have_http_status(:ok)
    rows = page.css("#invites-list .list-row")
    expect(rows.size).to eq(2)
    expect(rows[0].text).to include("Anonymous influencer", "2 connected voters")
    expect(rows[0].css("a.list-row-title")).to be_empty
    expect(rows[1].text).to include("Marisol Vega", "1 connected voter")
    expect(rows[1].at_css("a.list-row-title")["href"]).to eq(public_path)
    expect(response.body).not_to include("Elias", "Brooks", private_influencer.email, private_influencer.invite_token, "Rosa", "Delgado")
    expect(page.css("form[action='#{invites_path}']")).to be_empty
  end

  it "shows a public page with the count while keeping invited voters private" do
    get public_path

    expect(response).to have_http_status(:ok)
    expect(page.at_css("h1").text).to eq("Marisol Vega")
    expect(response.body).to include("1 connected voter", "Sign in to connect")
    expect(response.body).not_to include("Rosa", "Delgado", invitee.email)
  end

  it "returns not found for private, empty, and unknown influencer pages" do
    empty_influencer = create(:voter, public_influencer: true)
    [ private_influencer.invite_token, empty_influencer.invite_token, "unknown-token" ].each do |token|
      get influencer_path(token: token)
      expect(response).to have_http_status(:not_found)
    end
  end

  it "lets a voter opt into public visibility and withdraw it later" do
    expect(private_influencer).not_to be_public_influencer
    sign_in private_influencer

    get edit_voter_path(private_influencer)
    expect(page.at_css("input[type='checkbox'][name='voter[public_influencer]']")).to be_present
    patch voter_path(private_influencer), params: { voter: { public_influencer: "1" } }
    expect(private_influencer.reload).to be_public_influencer
    get influencer_path(token: private_influencer.invite_token)
    expect(response).to have_http_status(:ok)

    patch voter_path(private_influencer), params: { voter: { public_influencer: "0" } }
    expect(private_influencer.reload).not_to be_public_influencer
    get influencer_path(token: private_influencer.invite_token)
    expect(response).to have_http_status(:not_found)
    get invites_path
    expect(page.css("#invites-list .list-row").map(&:text).join).not_to include("Elias", "Brooks")
  end

  it "does not let another voter or an admin opt an influencer in" do
    sign_in invitee
    patch voter_path(private_influencer), params: { voter: { public_influencer: true } }
    expect(response).to redirect_to(root_path)
    expect(private_influencer.reload).not_to be_public_influencer

    sign_in create(:admin_voter)
    patch voter_path(private_influencer), params: { voter: { public_influencer: true } }
    expect(private_influencer.reload).not_to be_public_influencer
  end

  it "offers signed-in voters connect buttons on the leaderboard and public pages" do
    sign_in create(:voter)
    get invites_path
    expect(page.css("#invites-list form[action='#{invites_path}']").size).to eq(1)
    expect(response.body).not_to include("Elias", "Brooks", private_influencer.email, private_influencer.invite_token, "Rosa", "Delgado")
    expect(page.css("input[name='token']").map { it["value"] }).to contain_exactly(public_influencer.invite_token)

    get public_path
    form = page.at_css("form[action='#{invites_path}']")
    expect(form.at_css("input[name='token']")["value"]).to eq(public_influencer.invite_token)
    expect(form.at_css("button").text).to eq("Connect")
    expect(form["method"]).to eq("post")
  end

  it "connects to a public influencer without replacing earlier connections" do
    voter = create(:voter)
    private_influencer.invites.create!(invitee: voter)
    sign_in voter
    expect do
      post invites_path, params: { token: public_influencer.invite_token, source: "influencer" }
    end.to change(Invite, :count).by(1)
    expect(response).to redirect_to(public_path)
    follow_redirect!
    expect(response.body).to include("Connected", "2 connected voters")

    get invites_path
    expect(response.body).not_to include("Elias", "Brooks")
    expect(page.css("#invites-list .row-badge").map(&:text)).to eq([ "Connected" ])
    expect(voter.inviters).to contain_exactly(public_influencer, private_influencer)
  end

  it "rejects connections to influencers who are private, including from a stale public page" do
    voter = create(:voter)
    sign_in voter
    get public_path
    expect(page.at_css("form[action='#{invites_path}']")).to be_present
    public_influencer.update!(public_influencer: false)

    expect do
      post invites_path, params: { token: public_influencer.invite_token, source: "influencer" }
    end.not_to change(Invite, :count)
    expect(response).to have_http_status(:not_found)
    sign_in voter
    expect do
      post invites_path, params: { token: private_influencer.invite_token }
    end.not_to change(Invite, :count)
    expect(response).to have_http_status(:not_found)
  end

  it "treats repeat connections as an existing connection" do
    sign_in invitee
    expect do
      2.times { post invites_path, params: { token: public_influencer.invite_token } }
    end.not_to change(Invite, :count)
    expect(response).to redirect_to(invites_path)
  end

  it "does not connect anyone on a GET or when signed out" do
    expect { get public_path }.not_to change(Invite, :count)
    expect { get invites_path }.not_to change(Invite, :count)
    expect do
      post invites_path, params: { token: public_influencer.invite_token, invitee_id: invitee.id }
    end.not_to change(Invite, :count)
    expect(response).to redirect_to(new_voter_session_path)
  end

  it "cannot attach a different voter through submitted parameters" do
    voter = create(:voter)
    sign_in voter
    post invites_path, params: { token: public_influencer.invite_token, invitee_id: private_influencer.id, inviter_id: private_influencer.id }

    expect(voter.inviters).to contain_exactly(public_influencer)
    expect(private_influencer.received_invites).to be_empty
  end

  it "rejects self-connections and does not offer a connect button for oneself" do
    sign_in public_influencer
    get public_path
    expect(page.css("form[action='#{invites_path}']")).to be_empty
    expect(response.body).to include("You")

    expect do
      post invites_path, params: { token: public_influencer.invite_token }
    end.not_to change(Invite, :count)
    expect(response).to redirect_to(invites_path)
  end

  it "returns not found when a connection target no longer exists or has no invites" do
    post voter_session_path, params: { voter: { email: invitee.email, password: "password123" } }
    expect(response).to redirect_to(root_path)
    empty_influencer = create(:voter)
    [ "missing", empty_influencer.invite_token ].each do |token|
      expect { post invites_path, params: { token: token } }.not_to change(Invite, :count)
      expect(response).to have_http_status(:not_found)
    end
  end

  it "excludes voters with no connections and paginates the leaderboard" do
    outsiders = create_list(:voter, 32)
    outsiders.each { it.invites.create!(invitee: invitee) }
    create(:voter, first_name: "NoInvites", public_influencer: true)

    get invites_path
    first_page = page.css("#invites-list .list-row").map(&:text)
    expect(response).to have_http_status(:ok)
    expect(page.css("#invites-list .list-row").size).to eq(25)
    expect(page.at_css("a[rel='next']")).to be_present
    expect(response.body).not_to include("NoInvites")
    get page.at_css("a[rel='next']")["href"]
    expect(response).to have_http_status(:ok)
    expect(page.css("#invites-list .list-row")).not_to be_empty
    expect(page.css("#invites-list .list-row").map(&:text) & first_page).to be_empty
  end

  it "shows an empty state when there are no influencers" do
    Invite.delete_all
    get invites_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No invites yet")
    expect(page.css("#invites-list .list-row")).to be_empty
  end
end
