class Candidacy < ApplicationRecord
  belongs_to :person
  belongs_to :election
  has_many :ratings, dependent: :destroy
  has_many :rating_archives, dependent: :destroy
  has_many :stances, dependent: :destroy
  has_many :voters, through: :ratings
  
  validates :status, presence: true, inclusion: { in: %w[announced active withdrawn disqualified] }
  validates :announcement_date, presence: true
  
  scope :announced, -> { where(status: 'announced') }
  scope :active, -> { where(status: 'active') }
  scope :withdrawn, -> { where(status: 'withdrawn') }
  scope :disqualified, -> { where(status: 'disqualified') }
  
  scope :with_rating_details, -> { includes(:person, :ratings) }
  scope :with_election_context, -> { includes(election: [office: :position]) }
  
  def name
    "#{person.full_name} for #{election.office.position.title}"
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
