class VoterRaceBaseline < ApplicationRecord
  belongs_to :voter
  belongs_to :race

  validates :baseline, presence: true, inclusion: { in: 0..500 }
  validates :voter_id, uniqueness: { scope: :race_id, message: "can only have one baseline per race" }

  before_update :archive_previous_baseline
  before_destroy :archive_baseline_on_destroy

  def baseline_percentage
    (baseline / 500.0 * 100).round(1)
  end

  def name
    "#{voter.name} baseline for #{race.name}"
  end

  def approved_candidacies
    race.candidacies.joins(:ratings)
           .where(ratings: { voter: voter })
           .where("ratings.rating > ?", baseline)
  end

  def approval_count
    approved_candidacies.count
  end

  def voter_race_baseline_archives
    VoterRaceBaselineArchive.where(voter: voter, race: race)
  end

  def has_archives?
    voter_race_baseline_archives.exists?
  end

  def baseline_history
    voter_race_baseline_archives.recent
  end

  def previous_baseline_value
    baseline_history.first&.baseline
  end

  def baseline_changed_since_archive?
    return true unless previous_baseline_value
    baseline != previous_baseline_value
  end

  private

  def archive_previous_baseline
    if baseline_changed? && baseline_was.present?
      VoterRaceBaselineArchive.create!(
        voter: voter,
        race: race,
        baseline: baseline_was,
        previous_baseline: baseline_was,
        new_baseline: baseline,
        archived_at: Time.current,
        reason: "Baseline updated from #{baseline_was} to #{baseline}"
      )
    end
  end

  def archive_baseline_on_destroy
    VoterRaceBaselineArchive.create!(
      voter: voter,
      race: race,
      baseline: baseline,
      previous_baseline: baseline,
      new_baseline: nil,
      archived_at: Time.current,
      reason: "Baseline deleted (was #{baseline})"
    )
  end
end
