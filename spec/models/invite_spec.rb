require "rails_helper"

RSpec.describe Invite, type: :model do
  let(:inviter) { create(:voter) }
  let(:invitee) { create(:voter) }

  it "connects an inviter to the voters they invited" do
    invite = inviter.invites.create!(invitee: invitee)

    expect(inviter.invited_voters).to contain_exactly(invitee)
    expect(invitee.received_invites).to contain_exactly(invite)
    expect(invitee.inviters).to contain_exactly(inviter)
  end

  it "allows a voter to connect to multiple influencers" do
    other_inviter = create(:voter)
    inviter.invites.create!(invitee: invitee)
    other_inviter.invites.create!(invitee: invitee)

    expect(invitee.inviters).to contain_exactly(inviter, other_inviter)
  end

  it "allows each inviter and invitee pair only once" do
    inviter.invites.create!(invitee: invitee)
    duplicate = Invite.new(inviter: inviter, invitee: invitee)

    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:invitee_id]).to include("has already been taken")
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "prevents self-invites" do
    invite = Invite.new(inviter: inviter, invitee: inviter)

    expect(invite).not_to be_valid
    expect(invite.errors[:invitee]).to include("cannot be the inviter")
    expect { invite.save!(validate: false) }.to raise_error(ActiveRecord::StatementInvalid, /invites_cannot_invite_self/)
  end

  it "removes the connection when the inviter deletes their account" do
    inviter.invites.create!(invitee: invitee)

    expect { inviter.destroy! }.to change(Invite, :count).by(-1)
    expect(invitee.reload.received_invites).to be_empty
  end

  it "removes the connection when the invited voter deletes their account" do
    inviter.invites.create!(invitee: invitee)

    expect { invitee.destroy! }.to change(Invite, :count).by(-1)
    expect(inviter.reload.invited_voters).to be_empty
  end
end
