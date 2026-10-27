class VoterRaceBaseline < ApplicationRecord
  # Saved baseline changes a voter may make to one race in a day; ratings stay unlimited.
  DAILY_CHANGE_LIMIT = 5

  belongs_to :voter
  belongs_to :race

  # Whose results the mountain counts toward: the race's residents, or visitors trying a pretend vote.
  enum :counted_as, { resident: "resident", visitor: "visitor" }, validate: true

  validates :baseline, presence: true, inclusion: { in: 0..500 }
  validates :voter_id, uniqueness: { scope: :race_id, message: "can only have one baseline per race" }
  validate :within_daily_change_limit, on: :update, if: :will_save_change_to_baseline?

  before_update :archive_previous_baseline
  before_destroy :archive_baseline_on_destroy

  def self.changes_left_today(voter, race)
    [ DAILY_CHANGE_LIMIT - VoterRaceBaselineArchive.for_voter_and_race(voter, race).archived_today.count, 0 ].max
  end

  # Sorts every saved mountain into residents and visitors by where its voter lives now.
  def self.recount!
    includes(:voter, race: :office).find_each { it.update_columns(counted_as: it.race.counted_as_for(it.voter)) }
  end

  def changes_left_today
    self.class.changes_left_today(voter, race)
  end

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

  def within_daily_change_limit
    errors.add(:baseline, "can change #{DAILY_CHANGE_LIMIT} times a day; try again tomorrow") if changes_left_today.zero?
  end

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
