class InfluencerProfilePolicy < ApplicationPolicy
  def show?
    voter.present?
  end
end
