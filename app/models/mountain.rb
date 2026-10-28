# One voter's mountain for one race: the ratings and baseline they have saved, with any unsaved draft
# laid over them. Saving publishes the draft into ratings and the baseline, which archive what they
# replace, and fixes whether the mountain counts with the race's residents or with visitors.
class Mountain
  DEFAULT_BASELINE = 200
  PROGRESS_STATES = %w[saved started not_started].freeze

  attr_reader :voter, :race

  def initialize(voter:, race:)
    @voter = voter
    @race = race
  end

  def candidacies
    race.candidacies_for(voter)
  end

  def draft
    @draft ||= race.mountain_drafts.find_or_initialize_by(voter: voter)
  end

  def saved_baseline_record
    @saved_baseline_record ||= race.voter_race_baselines.find_by(voter: voter)
  end

  def saved_baseline
    saved_baseline_record&.baseline
  end

  def saved_ratings
    @saved_ratings ||= Rating.where(voter: voter, candidacy: candidacies).pluck(:candidacy_id, :rating).to_h
  end

  # The ratings as the voter sees them now, draft included; unrated candidacies are left out.
  def ratings
    saved_ratings.merge(draft.ratings_by_candidacy).compact
  end

  def baseline
    draft.baseline || saved_baseline || DEFAULT_BASELINE
  end

  def approved?(candidacy)
    baseline.present? && ratings.fetch(candidacy.id, -1) > baseline
  end

  # Approved candidacies on the ballot, highest rated first.
  def approved_candidacies
    candidacies.not_from_primaries.select { approved?(it) }.sort_by { -ratings[it.id] }
  end

  def not_approved_candidacies
    candidacies.not_from_primaries.reject { approved?(it) }
  end

  # Candidates from the primaries this voter rates above their line; they never change the ballot.
  def approved_off_ballot_candidacies
    candidacies.from_primaries.select { approved?(it) }
  end

  def ballot_candidacies_count
    candidacies.not_from_primaries.count
  end

  def rated_count
    ratings.slice(*candidacies.not_from_primaries.ids).size
  end

  # What saving would change: the candidacies whose rating moves, and the baseline's move, if any.
  def unsaved_changes
    previous_baseline = saved_baseline || DEFAULT_BASELINE
    {
      candidacy_ids: draft.ratings_by_candidacy.reject { |candidacy_id, value| saved_ratings[candidacy_id] == value }.keys,
      baseline: ([ previous_baseline, draft.baseline ] if draft.baseline && draft.baseline != previous_baseline)
    }
  end

  def unsaved?
    unsaved_changes[:candidacy_ids].any? || unsaved_changes[:baseline].present?
  end

  def progress
    if saved_baseline_record && !unsaved? then "saved"
    elsif unsaved? || saved_ratings.any? then "started"
    else "not_started"
    end
  end

  def baseline_changes_left_today
    VoterRaceBaseline.changes_left_today(voter, race)
  end

  # Folds edits into the server-side draft, and drops the draft once it matches what is saved.
  def revise_draft!(ratings: {}, baseline: nil)
    draft.revise(ratings: ratings, baseline: baseline)
    unsaved? ? draft.save! : discard!
    self
  end

  def discard!
    draft.destroy! if draft.persisted?
    @draft = nil
    self
  end

  def save!
    publish!(ratings: draft.ratings_by_candidacy, baseline: baseline)
  end

  # Writes ratings and a baseline straight to the saved mountain, replacing any draft. A blank rating
  # removes the saved one; a blank baseline removes the saved baseline.
  def publish!(ratings:, baseline:)
    ActiveRecord::Base.transaction do
      ratings.each { |candidacy_id, value| publish_rating!(candidacies.find(candidacy_id), value) }
      publish_baseline!(baseline)
      discard!
    end
    reload
  end

  def reload
    @saved_baseline_record = @saved_ratings = @draft = nil
    self
  end

  def as_json(*)
    {
      race_id: race.id,
      progress: progress,
      baseline: baseline,
      ratings: ratings,
      approved_candidacy_ids: approved_candidacies.map(&:id),
      approved_off_ballot_candidacy_ids: approved_off_ballot_candidacies.map(&:id),
      unsaved_changes: unsaved_changes,
      baseline_changes_left_today: baseline_changes_left_today
    }
  end

  private

  def publish_rating!(candidacy, value)
    rating = Rating.find_or_initialize_by(voter: voter, candidacy: candidacy)
    if value.present?
      rating.update!(rating: value.to_i.clamp(0, 500))
    elsif rating.persisted?
      rating.destroy!
    end
  end

  def publish_baseline!(value)
    if value.present?
      race.voter_race_baselines.find_or_initialize_by(voter: voter)
        .update!(baseline: value.to_i.clamp(0, 500), counted_as: race.counted_as_for(voter))
    else
      saved_baseline_record&.destroy!
    end
  end
end
