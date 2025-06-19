class Year < ApplicationRecord
  has_many :elections, dependent: :destroy
  
  validates :year, presence: true, uniqueness: true
  validates :is_even_year, inclusion: { in: [true, false] }
  validates :is_presidential_year, inclusion: { in: [true, false] }
  
  scope :even_years, -> { where(is_even_year: true) }
  scope :presidential_years, -> { where(is_presidential_year: true) }

  def name
    year
  end
end
