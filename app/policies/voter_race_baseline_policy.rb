# frozen_string_literal: true

# A baseline reveals where one voter draws approval in a race, so only that voter, or an admin, may see it.
class VoterRaceBaselinePolicy < ApplicationRecordPolicy
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
