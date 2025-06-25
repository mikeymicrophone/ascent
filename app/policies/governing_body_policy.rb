# frozen_string_literal: true

class GoverningBodyPolicy < ApplicationPolicy
  # Voters can view and create governing bodies
  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    create?
  end

  def edit?
    true
  end

  def update?
    edit?
  end

  # Voters cannot delete governing bodies
  def destroy?
    false
  end
end