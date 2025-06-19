class Rating < ApplicationRecord
  belongs_to :voter
  belongs_to :candidacy
  
  validates :rating, presence: true, inclusion: { in: 0..500 }
  validates :voter_id, uniqueness: { scope: :candidacy_id, message: "can only rate each candidacy once" }
  validate :voter_eligible_for_election
  
  before_update :archive_previous_rating
  
  scope :above_baseline, ->(baseline) { where("rating >= ?", baseline) }
  scope :below_baseline, ->(baseline) { where("rating < ?", baseline) }
  scope :for_election, ->(election) { joins(:candidacy).where(candidacies: { election: election }) }
  
  def approved?(baseline = nil)
    baseline ||= voter_baseline_for_election
    return false unless baseline
    rating >= baseline
  end
  
  def name
    "#{voter.name} rating for #{candidacy.person.name}"
  end
  
  def rating_percentage
    (rating / 500.0 * 100).round(1)
  end
  
  def voter_baseline_for_election
    voter.voter_election_baselines.find_by(election: candidacy.election)&.baseline
  end
  
  private
  
  def voter_eligible_for_election
    unless voter.eligible_for_election?(candidacy.election)
      errors.add(:voter, "is not eligible to vote in this election")
    end
  end
  
  def archive_previous_rating
    if rating_changed?
      RatingArchive.create!(
        voter: voter,
        candidacy: candidacy,
        rating: rating_was || rating,
        archived_at: Time.current,
        reason: "Updated rating: #{rating_was} → #{rating}"
      )
    end
  end
end
