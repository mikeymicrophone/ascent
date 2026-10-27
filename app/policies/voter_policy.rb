# frozen_string_literal: true

class VoterPolicy < ApplicationRecordPolicy
  def index?
    admin?
  end

  def show?
    admin? || own_record?
  end

  def edit?
    admin? || own_record?
  end

  def update?
    edit?
  end

  def destroy?
    admin?
  end

  private

  def own_record?
    voter.present? && record == voter
  end
end
