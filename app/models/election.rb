class Election < ApplicationRecord
  belongs_to :office
  belongs_to :year
  
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
end
