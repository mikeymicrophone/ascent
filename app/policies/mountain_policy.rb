# frozen_string_literal: true

# A mountain is one voter's ratings and baseline for a race, so only that voter, or an admin, may
# see or change it. The record is the voter whose mountain it is. Simulated data invents candidates
# and ratings, so only admins may make it.
class MountainPolicy < ApplicationPolicy
  alias_rule :edit?, :update?, :primary_candidates?, to: :show?

  def index?
    true
  end

  def show?
    voter.present? && (voter.admin? || record == voter)
  end

  def simulate?
    voter&.admin? || false
  end
end
