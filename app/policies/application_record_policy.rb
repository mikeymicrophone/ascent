# frozen_string_literal: true

class ApplicationRecordPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def edit?
    admin?
  end

  def update?
    edit?
  end

  def destroy?
    admin?
  end

  # Any other action, such as a mountain's simulate, is for admins.
  def manage?
    admin?
  end

  private

  def admin?
    voter&.admin?
  end

  def moderator?
    voter&.can_moderate?
  end

  def reviewer?
    voter&.can_review?
  end
end
