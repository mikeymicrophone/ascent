# How a voter treats one race. Each preference is off until the voter turns it on.
class VoterRacePreference < ApplicationRecord
  belongs_to :voter
  belongs_to :race

  validates :race_id, uniqueness: { scope: :voter_id }
end
