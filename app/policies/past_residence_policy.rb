# frozen_string_literal: true

# A voter keeps their own residence history; they may remove a past residence, never a current one, and
# may move out of a place they live now.
class PastResidencePolicy < ApplicationPolicy
  def index?
    voter.present?
  end
  alias_method :new?, :index?
  alias_method :create?, :index?

  def destroy?
    own? && record.ended_on.present?
  end

  def move_out?
    own? && record.current?
  end

  private

  def own?
    voter.present? && record.voter_id == voter.id
  end
end
