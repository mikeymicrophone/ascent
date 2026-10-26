# frozen_string_literal: true

# A ballot shows where a voter lives and how they are rating, so it is only ever the signed-in voter's own.
class BallotPolicy < ApplicationPolicy
  def show?
    voter.present?
  end
end
