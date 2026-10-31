require "rails_helper"

RSpec.describe "Invite links", type: :request do
  let!(:inviter) { create(:voter, first_name: "Marisol", last_name: "Vega") }
  let(:signup) do
    { first_name: "Rosa", last_name: "Delgado", email: "rosa.delgado@example.com",
      password: "long-enough-password", password_confirmation: "long-enough-password" }
  end

  def open_invite(voter = inviter)
    get invite_path(token: voter.invite_token)
  end

  def register(attributes = signup)
    post voter_registration_path, params: { voter: attributes }
  end

  it "shows a voter's stable invite URL on their profile form" do
    token = inviter.invite_token
    expect(inviter.reload.invite_token).to eq(token)
    expect(create(:voter).invite_token).not_to eq(token)
    sign_in inviter

    get edit_voter_path(inviter)

    expect(response).to have_http_status(:ok)
    link = Nokogiri::HTML(response.body).at_css("a[href='#{invite_path(token: token)}']")
    expect(link.text).to eq(invite_url(token: token))
  end

  it "records an invite when a visitor registers after following the URL" do
    open_invite
    expect(response).to redirect_to(new_voter_registration_path)
    expect(response.headers["Cache-Control"]).to include("no-store")
    follow_redirect!
    expect(response).to have_http_status(:ok)
    get root_path

    expect { register }.to change(Invite, :count).by(1)

    invitee = Voter.find_by!(email: signup[:email])
    expect(invitee.inviters).to contain_exactly(inviter)
    expect(invitee).not_to be_confirmed
    expect(response).to have_http_status(:redirect)
  end

  it "keeps the invite through a failed signup and records it only after success" do
    open_invite

    expect { register(signup.merge(first_name: "")) }.not_to change(Invite, :count)
    expect(response).to have_http_status(:unprocessable_content)
    expect(Voter.exists?(email: signup[:email])).to be(false)

    expect { register }.to change(Invite, :count).by(1)
    expect(Voter.find_by!(email: signup[:email]).inviters).to contain_exactly(inviter)
  end

  it "allows registration without an invite" do
    expect { register }.not_to change(Invite, :count)
    expect(Voter.find_by!(email: signup[:email]).received_invites).to be_empty
  end

  it "returns not found for an unknown token" do
    get invite_path(token: "unknown-token")

    expect(response).to have_http_status(:not_found)
    expect { register }.not_to change(Invite, :count)
  end

  it "uses the most recently opened valid invite link" do
    other_inviter = create(:voter)
    open_invite
    open_invite(other_inviter)
    register

    expect(Voter.find_by!(email: signup[:email]).inviters).to contain_exactly(other_inviter)
  end

  it "does not change an existing voter's connection when they open a link" do
    invitee = create(:voter)
    existing = inviter.invites.create!(invitee: invitee)
    sign_in invitee

    expect { open_invite(create(:voter)) }.not_to change(Invite, :count)

    expect(response).to redirect_to(root_path)
    expect(invitee.reload.received_invites).to contain_exactly(existing)
  end

  it "discards a pending invite when the visitor signs into an existing account" do
    voter = create(:voter)
    open_invite
    post voter_session_path, params: { voter: { email: voter.email, password: "password123" } }
    expect(response).to redirect_to(root_path)
    delete destroy_voter_session_path

    expect { register }.not_to change(Invite, :count)
  end

  it "does not carry an invite into a second signup in the same browser" do
    open_invite
    register

    expect { register(signup.merge(email: "eli.brooks@example.com")) }.not_to change(Invite, :count)
    expect(Voter.find_by!(email: "eli.brooks@example.com").received_invites).to be_empty
  end

  it "ignores submitted inviter IDs and tokens that did not come through a link" do
    expect do
      register(signup.merge(inviter_id: inviter.id, invite_token: inviter.invite_token,
        received_invites_attributes: [ { inviter_id: inviter.id } ]))
    end.not_to change(Invite, :count)

    expect(Voter.find_by!(email: signup[:email]).invite_token).not_to eq(inviter.invite_token)
  end

  it "allows signup if the inviter deleted their account after the link was opened" do
    open_invite
    inviter.destroy!

    expect { register }.not_to change(Invite, :count)
    expect(Voter.find_by!(email: signup[:email]).received_invites).to be_empty
  end
end
