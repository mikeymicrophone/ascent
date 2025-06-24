class VoterElectionBaseline < ApplicationRecord
  belongs_to :voter
  belongs_to :election
  # Archives are found through matching voter and election

  validates :baseline, presence: true, inclusion: { in: 0..500 }
  validates :voter_id, uniqueness: { scope: :election_id, message: "can only have one baseline per election" }
  # validate :voter_eligible_for_election

  before_update :archive_previous_baseline
  before_destroy :archive_baseline_on_destroy

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

  def voter_election_baseline_archives
    VoterElectionBaselineArchive.where(voter: voter, election: election)
  end

  def has_archives?
    voter_election_baseline_archives.exists?
  end

  # Get the history of baseline changes for this voter and election
  def baseline_history
    voter_election_baseline_archives.recent
  end

  # Get the most recent archived baseline
  def previous_baseline_value
    baseline_history.first&.baseline
  end

  # Check if baseline has changed since last archive
  def baseline_changed_since_archive?
    return true unless previous_baseline_value
    baseline != previous_baseline_value
  end

  private

  def voter_eligible_for_election
    unless voter.eligible_for_election?(election)
      errors.add(:voter, "is not eligible to participate in this election")
    end
  end

  def archive_previous_baseline
    if baseline_changed? && baseline_was.present?
      VoterElectionBaselineArchive.create!(
        voter: voter,
        election: election,
        baseline: baseline_was,
        previous_baseline: baseline_was,
        new_baseline: baseline,
        archived_at: Time.current,
        reason: "Baseline updated from #{baseline_was} to #{baseline}"
      )
    end
  end

  def archive_baseline_on_destroy
    VoterElectionBaselineArchive.create!(
      voter: voter,
      election: election,
      baseline: baseline,
      previous_baseline: baseline,
      new_baseline: nil,
      archived_at: Time.current,
      reason: "Baseline deleted (was #{baseline})"
    )
  end
end
