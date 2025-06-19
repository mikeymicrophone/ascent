class VoterElectionBaseline < ApplicationRecord
  belongs_to :voter
  belongs_to :election
  
  validates :baseline, presence: true, inclusion: { in: 0..500 }
  validates :voter_id, uniqueness: { scope: :election_id, message: "can only have one baseline per election" }
  validate :voter_eligible_for_election
  
  def baseline_percentage
    (baseline / 500.0 * 100).round(1)
  end
  
  def name
    "#{voter.name} baseline for #{election.name}"
  end
  
  # Get approved candidacies based on this baseline
  def approved_candidacies
    election.candidacies.joins(:ratings)
           .where(ratings: { voter: voter })
           .where("ratings.rating >= ?", baseline)
  end
  
  # Count of approved candidates
  def approval_count
    approved_candidacies.count
  end
  
  private
  
  def voter_eligible_for_election
    unless voter.eligible_for_election?(election)
      errors.add(:voter, "is not eligible to participate in this election")
    end
  end
end
