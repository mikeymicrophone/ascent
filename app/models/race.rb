class Race < ApplicationRecord
  belongs_to :election
  belongs_to :office
  has_many :candidacies, dependent: :destroy
  has_many :candidates, through: :candidacies, source: :person
  has_many :voter_race_baselines, dependent: :destroy
  has_many :voter_race_baseline_archives, dependent: :delete_all

  validates :status, presence: true, inclusion: { in: %w[upcoming active completed cancelled] }
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

      voter_ratings = Rating.joins(:candidacy)
                           .where(voter: voter, candidacies: { race: self })
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

  def office_matches_election_jurisdiction
    if office && election && office.jurisdiction != election.jurisdiction
      errors.add(:office, "must belong to the election's jurisdiction")
    end
  end
end
