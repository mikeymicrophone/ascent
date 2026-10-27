# frozen_string_literal: true

# Any signed-in voter may say where they live; a claim only ever changes their own residence.
class ResidenceClaimPolicy < ApplicationPolicy
  def new?
    voter.present?
  end
  alias_method :preview?, :new?
  alias_method :create?, :new?
end
