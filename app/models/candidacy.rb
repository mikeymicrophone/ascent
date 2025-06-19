class Candidacy < ApplicationRecord
  belongs_to :person
  belongs_to :election
  
  validates :status, presence: true, inclusion: { in: %w[announced active withdrawn disqualified] }
  validates :announcement_date, presence: true
  
  scope :announced, -> { where(status: 'announced') }
  scope :active, -> { where(status: 'active') }
  scope :withdrawn, -> { where(status: 'withdrawn') }
  scope :disqualified, -> { where(status: 'disqualified') }
  
  def name
    "#{person.full_name} for #{election.office.position.title}"
  end
end
