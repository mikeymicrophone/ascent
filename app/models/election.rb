class Election < ApplicationRecord
  belongs_to :office
  belongs_to :year
  has_many :candidacies, dependent: :destroy
  has_many :candidates, through: :candidacies, source: :person
  has_many :voter_election_baselines, dependent: :destroy
  
  validates :status, presence: true, inclusion: { in: %w[upcoming active completed cancelled] }
  validates :is_mock, inclusion: { in: [true, false] }
  validates :is_historical, inclusion: { in: [true, false] }
  validates :election_date, presence: true
  
  scope :upcoming, -> { where(status: 'upcoming') }
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :mock, -> { where(is_mock: true) }
  scope :historical, -> { where(is_historical: true) }
  scope :real, -> { where(is_mock: false, is_historical: false) }
  
  def name
    "#{office.name} - #{year.year}"
  end
  
  # Aggregates approval votes for this election based on voter baselines
  # Returns a hash with Candidacy objects as keys and vote counts as values
  # A vote is counted when a voter's rating for a candidacy meets or exceeds their baseline
  #
  # @return [Hash<Candidacy, Integer>] candidacy => approval vote count
  def aggregate_votes
    results = {}
    
    # Initialize all candidacies with zero votes
    candidacies.each { |candidacy| results[candidacy] = 0 }
    
    # Count approval votes for each candidacy
    voter_election_baselines.includes(:voter).each do |baseline|
      voter = baseline.voter
      voter_baseline = baseline.baseline
      
      # Get all ratings by this voter for candidacies in this election
      voter_ratings = Rating.joins(:candidacy)
                           .where(voter: voter, candidacies: { election: self })
                           .includes(:candidacy)
      
      # Count approval votes (ratings at or above baseline)
      voter_ratings.each do |rating|
        if rating.rating >= voter_baseline
          results[rating.candidacy] += 1
        end
      end
    end
    
    results
  end
  
  # Returns approval vote results sorted by vote count (descending)
  # @return [Array<Array>] Array of [candidacy, vote_count] pairs, sorted by votes
  def approval_results
    aggregate_votes.sort_by { |candidacy, votes| -votes }
  end
  
  # Returns the winning candidacy (most approval votes)
  # @return [Candidacy, nil] The candidacy with the most votes, or nil if no votes
  def approval_winner
    results = aggregate_votes
    return nil if results.empty? || results.values.all?(&:zero?)
    
    results.max_by { |candidacy, votes| votes }&.first
  end
  
  # Returns the approval vote count for a specific candidacy
  # @param candidacy [Candidacy] The candidacy to get results for
  # @return [Integer] Number of approval votes for this candidacy
  def result_for(candidacy)
    aggregate_votes[candidacy] || 0
  end
  
  # Returns summary statistics for the election results
  # @return [Hash] Summary statistics including total votes, participation, etc.
  def results_summary
    results = aggregate_votes
    total_possible_voters = voter_election_baselines.count
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
end
