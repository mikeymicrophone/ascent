class Rating < ApplicationRecord
  belongs_to :voter
  belongs_to :candidacy
  
  validates :rating, presence: true, inclusion: { in: 0..500 }
  validates :baseline, presence: true, inclusion: { in: 0..500 }
  validates :voter_id, uniqueness: { scope: :candidacy_id, message: "can only rate each candidacy once" }
  validate :voter_eligible_for_election
  
  before_update :archive_previous_rating
  
  scope :approved, ->(baseline_threshold = nil) { 
    threshold = baseline_threshold || :baseline
    where("rating >= #{threshold.is_a?(Symbol) ? threshold : threshold}")
  }
  scope :above_baseline, -> { where("rating >= baseline") }
  scope :below_baseline, -> { where("rating < baseline") }
  
  def approved?
    rating >= baseline
  end
  
  def name
    "#{voter.name} rating for #{candidacy.person.name}"
  end
  
  def rating_percentage
    (rating / 500.0 * 100).round(1)
  end
  
  def baseline_percentage
    (baseline / 500.0 * 100).round(1)
  end
  
  private
  
  def voter_eligible_for_election
    unless voter.eligible_for_election?(candidacy.election)
      errors.add(:voter, "is not eligible to vote in this election")
    end
  end
  
  def archive_previous_rating
    if rating_changed? || baseline_changed?
      RatingArchive.create!(
        voter: voter,
        candidacy: candidacy,
        rating: rating_was || rating,
        baseline: baseline_was || baseline,
        archived_at: Time.current,
        reason: build_archive_reason
      )
    end
  end
  
  def build_archive_reason
    changes_desc = []
    changes_desc << "rating: #{rating_was} → #{rating}" if rating_changed?
    changes_desc << "baseline: #{baseline_was} → #{baseline}" if baseline_changed?
    "Updated: #{changes_desc.join(', ')}"
  end
end
