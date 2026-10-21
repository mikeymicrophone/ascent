class Candidacy < ApplicationRecord
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
  
  validates :status, presence: true, inclusion: { in: %w[announced active withdrawn disqualified] }
  # Whether a simulated slate includes the candidacy; separate from its official status.
  validates :participation, inclusion: { in: %w[active inactive off_ballot] }
  
  scope :announced, -> { where(status: 'announced') }
  scope :active, -> { where(status: 'active') }
  scope :withdrawn, -> { where(status: 'withdrawn') }
  scope :disqualified, -> { where(status: 'disqualified') }
  
  scope :with_rating_details, -> { includes(:person, :ratings, :ballot_lines) }
  scope :with_election_context, -> { includes(race: [:election, { office: :position }]) }
  
  def name
    "#{person.full_name} for #{office.position.title}"
  end
  
  # The printed labels, in ballot order, for display.
  def ballot_labels
    ballot_lines.map(&:label).join("; ").presence
  end

  def average_rating
    ratings.average(:rating)&.round(1)
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
