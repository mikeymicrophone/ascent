# frozen_string_literal: true

# A rating reveals how one voter feels about a candidate, so only that voter, or an admin, may see it.
class RatingPolicy < ApplicationRecordPolicy
  def index?
    admin?
  end

  def show?
    admin? || own_record?
  end

  private

  def own_record?
    voter.present? && record.voter_id == voter.id
  end
end
