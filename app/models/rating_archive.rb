class RatingArchive < ApplicationRecord
  belongs_to :voter
  belongs_to :candidacy
  
  validates :rating, presence: true, inclusion: { in: 0..500 }
  validates :baseline, presence: true, inclusion: { in: 0..500 }
  validates :archived_at, presence: true
  validates :reason, presence: true
  
  scope :recent, -> { order(archived_at: :desc) }
  scope :for_voter, ->(voter) { where(voter: voter) }
  scope :for_candidacy, ->(candidacy) { where(candidacy: candidacy) }
  
  def rating_percentage
    (rating / 500.0 * 100).round(1)
  end
  
  def baseline_percentage
    (baseline / 500.0 * 100).round(1)
  end
  
  def was_approved?
    rating >= baseline
  end
end
