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

  private

  def admin?
    voter&.admin?
  end
end
