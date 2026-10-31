# frozen_string_literal: true

class VoterPolicy < ApplicationRecordPolicy
  def index?
    moderator?
  end

  def show?
    moderator? || own_record?
  end

  def view_voting_activity?
    admin? || own_record?
  end

  def edit?
    admin? || own_record?
  end

  def update?
    edit?
  end

  def hide_profile?
    moderator? && !own_record?
  end

  def destroy?
    admin?
  end

  private

  def own_record?
    voter.present? && record == voter
  end
end
