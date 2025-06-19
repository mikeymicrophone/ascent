class Candidacy < ApplicationRecord
  belongs_to :person
  belongs_to :election
  has_many :ratings, dependent: :destroy
  has_many :rating_archives, dependent: :destroy
  has_many :voters, through: :ratings
  
  validates :status, presence: true, inclusion: { in: %w[announced active withdrawn disqualified] }
  validates :announcement_date, presence: true
  
  scope :announced, -> { where(status: 'announced') }
  scope :active, -> { where(status: 'active') }
  scope :withdrawn, -> { where(status: 'withdrawn') }
  scope :disqualified, -> { where(status: 'disqualified') }
  
  def name
    "#{person.full_name} for #{election.office.position.title}"
  end
  
  def average_rating
    ratings.average(:rating)&.round(1)
  end
  
  def approval_count
    ratings.above_baseline.count
  end
  
  def approval_percentage
    return 0 if ratings.count == 0
    (approval_count.to_f / ratings.count * 100).round(1)
  end
end
