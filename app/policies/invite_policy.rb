class InvitePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    voter.present?
  end
end
