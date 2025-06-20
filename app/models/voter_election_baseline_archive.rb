class VoterElectionBaselineArchive < ApplicationRecord
  belongs_to :voter
  belongs_to :election
  
  validates :baseline, presence: true, inclusion: { in: 0..500 }
  validates :archived_at, presence: true
  validates :reason, presence: true
  validates :previous_baseline, inclusion: { in: 0..500 }
  validates :new_baseline, inclusion: { in: 0..500 }, allow_nil: true
  
  scope :recent, -> { order(archived_at: :desc) }
  scope :for_voter, ->(voter) { where(voter: voter) }
  scope :for_election, ->(election) { where(election: election) }
  scope :for_voter_and_election, ->(voter, election) { where(voter: voter, election: election) }
  scope :baseline_changes, -> { where.not(previous_baseline: nil) }
  
  def baseline_percentage
    (baseline / 500.0 * 100).round(1)
  end
  
  def previous_baseline_percentage
    return nil unless previous_baseline
    (previous_baseline / 500.0 * 100).round(1)
  end
  
  def new_baseline_percentage
    return nil unless new_baseline
    (new_baseline / 500.0 * 100).round(1)
  end
  
  def baseline_change
    return nil unless previous_baseline && new_baseline
    new_baseline - previous_baseline
  end
  
  def baseline_change_percentage
    return nil unless previous_baseline && new_baseline && previous_baseline > 0
    ((baseline_change.to_f / previous_baseline) * 100).round(1)
  end
  
  def name
    if baseline_change
      change_direction = baseline_change.positive? ? "increased" : "decreased"
      "#{voter.name} baseline #{change_direction} for #{election.name}"
    else
      "#{voter.name} baseline archived for #{election.name}"
    end
  end
  
  # Class method to create archive from existing baseline
  def self.archive_baseline(voter_election_baseline, reason:, new_baseline: nil)
    create!(
      voter: voter_election_baseline.voter,
      election: voter_election_baseline.election,
      baseline: voter_election_baseline.baseline,
      previous_baseline: voter_election_baseline.baseline,
      new_baseline: new_baseline,
      archived_at: Time.current,
      reason: reason
    )
  end
end