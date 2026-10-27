# frozen_string_literal: true

# Any signed-in voter may make a mock election; only its creator, or an admin, may remove it.
# The record is the mock Election.
class MockElectionPolicy < ApplicationPolicy
  def create?
    voter.present?
  end
  alias_method :new?, :create?

  def destroy?
    voter.present? && record.is_mock && (voter.admin? || record.creator_id == voter.id)
  end
end
