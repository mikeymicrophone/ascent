class VoterLinkPolicy < ApplicationPolicy
  def create?
    voter.present?
  end

  def update?
    voter.present? && record.voter_id == voter.id
  end

  def move?
    update?
  end
end
