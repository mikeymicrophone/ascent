class Candidacy < ApplicationRecord
  include Engageable

  belongs_to :person
  belongs_to :race
  has_one :election, through: :race
  has_one :office, through: :race
  has_many :ratings, dependent: :destroy
  has_many :rating_archives, dependent: :destroy
  has_many :stances, dependent: :destroy
  has_many :ballot_lines, -> { printed_order }, dependent: :destroy
  has_many :endorsements, dependent: :destroy
  has_many :communication_features, dependent: :destroy
  has_many :featured_communications, through: :communication_features, source: :communication
  has_many :voters, through: :ratings
  # A general's off-ballot candidacy for someone who ran in a primary for its nomination.
  belongs_to :primary_candidacy, class_name: "Candidacy", optional: true, inverse_of: :general_candidacies
  has_many :general_candidacies, class_name: "Candidacy", foreign_key: :primary_candidacy_id, dependent: :destroy, inverse_of: :primary_candidacy

  validates :status, presence: true, inclusion: { in: %w[announced active withdrawn disqualified] }
  # Whether a simulated slate includes the candidacy; separate from its official status.
  validates :participation, inclusion: { in: %w[active inactive off_ballot] }

  scope :announced, -> { where(status: "announced") }
  scope :active, -> { where(status: "active") }
  scope :withdrawn, -> { where(status: "withdrawn") }
  scope :disqualified, -> { where(status: "disqualified") }
  scope :still_running, -> { where.not(status: %w[withdrawn disqualified]) }
  scope :from_primaries, -> { where.not(primary_candidacy_id: nil) }
  scope :not_from_primaries, -> { where(primary_candidacy_id: nil) }

  scope :with_rating_details, -> { includes(:person, :ratings, :ballot_lines) }
  scope :with_election_context, -> { includes(race: [ :election, { office: :position } ]) }

  def name
    "#{person.full_name} for #{office.position.title}"
  end

  # The printed labels, in ballot order, for display.
  def ballot_labels
    ballot_lines.map(&:label).join("; ").presence
  end

  # The printed labels, or for a primary candidate gathered into a general, the primary they ran in.
  def ballot_summary
    ballot_labels || (primary_summary if primary_candidacy)
  end

  def primary_summary
    organization = primary_candidacy.office.nominating_organization
    "Off the ballot; ran in the #{organization.is_a?(Party) ? "#{organization.name} primary" : organization.name}"
  end

  def average_rating
    ratings.average(:rating)&.round(1)
  end

  # Voters who rated this candidacy above their own baseline in its race, the way the race's results
  # count them: a candidacy from a primary counts only voters who include primary candidates there.
  def approvals_count
    approving = ratings.joins(voter: :voter_race_baselines)
                       .where(voter_race_baselines: { race_id: race_id })
                       .where("ratings.rating > voter_race_baselines.baseline")
    approving = approving.where(voter_id: VoterRacePreference.where(race_id: race_id, include_primary_candidates: true).select(:voter_id)) if primary_candidacy_id
    approving.count
  end

  def approval_count(baseline = nil)
    return 0 unless baseline
    ratings.above_baseline(baseline).count
  end

  def approval_percentage(baseline = nil)
    return 0 if ratings.count == 0 || baseline.nil?
    (approval_count(baseline).to_f / ratings.count * 100).round(1)
  end
end
