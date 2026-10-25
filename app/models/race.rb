class Race < ApplicationRecord
  STATUSES = %w[upcoming active completed cancelled].freeze

  include Engageable

  belongs_to :election
  belongs_to :office
  has_many :candidacies, dependent: :destroy
  has_many :candidates, through: :candidacies, source: :person
  has_many :voter_race_baselines, dependent: :destroy
  has_many :voter_race_baseline_archives, dependent: :delete_all
  has_many :voter_race_preferences, dependent: :delete_all

  validates :status, presence: true, inclusion: { in: STATUSES }
  # An updateable fact about the source's list, kept out of the race's identity and code.
  validates :certification_status, inclusion: { in: %w[certified tentative unofficial] }, allow_nil: true
  validate :office_matches_election_jurisdiction

  scope :upcoming, -> { where(status: 'upcoming') }
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :mock, -> { joins(:election).merge(Election.mock) }
  scope :historical, -> { joins(:election).merge(Election.historical) }
  scope :real, -> { joins(:election).merge(Election.real) }
  scope :recent, -> { joins(:election).order('elections.election_date DESC') }
  scope :with_full_details, -> { includes(:office, :candidates, :candidacies) }
  scope :with_candidacy_details, -> { includes(candidacies: [ :person, :ratings ]) }
  scope :with_office_context, -> { includes(office: :position) }
  scope :with_naming_details, -> { includes(election: :year, office: [ :position, { jurisdiction: :jurisdictionable } ]) }

  scope :in_state, ->(state) {
    state.jurisdiction ? joins(:office).where(offices: { jurisdiction_id: state.jurisdiction.self_and_descendants.select(:id) }) : none
  }

  scope :matching, ->(query) {
    pattern = "%#{sanitize_sql_like(query.strip)}%"
    candidates = Candidacy.joins(:person)
      .where("concat_ws(' ', people.first_name, people.middle_name, people.last_name) ILIKE ?", pattern)
    joins(:election, office: :position).where(
      "positions.title ILIKE :pattern OR elections.name ILIKE :pattern OR races.description ILIKE :pattern OR races.id IN (:candidate_races)",
      pattern: pattern, candidate_races: candidates.select(:race_id)
    )
  }

  delegate :election_date, :year, to: :election
  delegate :current_office_holder, to: :office

  def name
    "#{office.name} - #{year.year}"
  end

  def aggregate_votes
    results = {}

    candidacies.each { |candidacy| results[candidacy] = 0 }

    voter_race_baselines.includes(:voter).each do |baseline|
      voter = baseline.voter
      voter_baseline = baseline.baseline

      voter_ratings = Rating.where(voter: voter, candidacy: candidacies_for(voter))
                           .includes(:candidacy)

      voter_ratings.each do |rating|
        if rating.rating > voter_baseline
          results[rating.candidacy] += 1
        end
      end
    end

    results
  end

  def approval_results
    aggregate_votes.sort_by { |candidacy, votes| -votes }
  end

  # The candidacies a voter sees and rates: those the primaries eliminated only if they opted in.
  def candidacies_for(voter)
    voter&.includes_primary_candidates?(self) ? candidacies : candidacies.not_from_primaries
  end

  # The same year's primaries for this office's nominations, such as each party's primary for governor.
  def nomination_races
    Race.joins(:election).where(office: office.nominations, elections: { year_id: election.year_id })
  end

  # Gives everyone still running in this office's primaries a candidacy here, off the ballot unless
  # the data places them on it, so a simulated approval vote can rate those the primary eliminated.
  # Returns the candidacies it added.
  def gather_primary_candidates!
    running = Candidacy.where(race: nomination_races).still_running.order(:id).group_by(&:person_id)
    gathered = candidacies.from_primaries.includes(:primary_candidacy).index_by(&:person_id)
    gathered.each { |person_id, candidacy| candidacy.destroy! unless running.key?(person_id) }
    placed = candidacies.pluck(:person_id).to_set
    running.each do |person_id, primary_candidacies|
      candidacy = gathered[person_id]
      candidacy.update!(primary_candidacy: primary_candidacies.first) if candidacy && !primary_candidacies.include?(candidacy.primary_candidacy)
    end
    running.except(*placed).map do |_person_id, primary_candidacies|
      candidacies.create!(person_id: primary_candidacies.first.person_id, primary_candidacy: primary_candidacies.first, status: "active", participation: "off_ballot")
    end
  end

  # Every general with nominations, plus any that still holds candidacies from primaries since removed.
  def self.gather_primary_candidates!
    where(office_id: Office.nominations.select(:nominee_for_office_id)).or(where(id: Candidacy.from_primaries.select(:race_id)))
      .where.not(election_id: Election.primaries.select(:id))
      .includes(:election, :office).find_each.flat_map(&:gather_primary_candidates!)
  end

  def approval_winner
    results = aggregate_votes
    return nil if results.empty? || results.values.all?(&:zero?)

    results.max_by { |candidacy, votes| votes }&.first
  end

  def result_for(candidacy)
    aggregate_votes[candidacy] || 0
  end

  def results_summary
    results = aggregate_votes
    total_possible_voters = voter_race_baselines.count
    total_votes_cast = results.values.sum

    {
      total_candidacies: candidacies.count,
      total_registered_voters: total_possible_voters,
      total_approval_votes: total_votes_cast,
      average_approvals_per_voter: total_possible_voters.zero? ? 0 : (total_votes_cast.to_f / total_possible_voters).round(2),
      winner: approval_winner&.person&.name,
      winning_vote_count: results.values.max || 0
    }
  end

  private

  # One election day can decide offices across its jurisdiction, such as a state primary's district nominations.
  def office_matches_election_jurisdiction
    if office && election && !election.jurisdiction.contains?(office.jurisdiction)
      errors.add(:office, "must be within the election's jurisdiction")
    end
  end
end
