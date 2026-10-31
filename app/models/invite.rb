class Invite < ApplicationRecord
  belongs_to :inviter, class_name: "Voter", inverse_of: :invites
  belongs_to :invitee, class_name: "Voter", inverse_of: :received_invites

  validates :invitee_id, uniqueness: { scope: :inviter_id }
  validate :cannot_invite_self

  private

  def cannot_invite_self
    errors.add(:invitee, "cannot be the inviter") if inviter == invitee
  end
end
