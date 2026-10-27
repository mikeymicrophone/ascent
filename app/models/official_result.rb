# One candidacy's certified votes in a finished race.
class OfficialResult < ApplicationRecord
  belongs_to :race
  belongs_to :candidacy

  validates :votes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :vote_share, numericality: { in: 0..100 }, allow_nil: true
  validates :candidacy_id, uniqueness: { scope: :race_id }
  validate :candidacy_ran_in_race

  scope :winners, -> { where(winner: true) }
  scope :by_votes, -> { order(votes: :desc) }

  private

  def candidacy_ran_in_race
    errors.add(:candidacy, "must have run in this race") if candidacy && candidacy.race_id != race_id
  end
end
