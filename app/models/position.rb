class Position < ApplicationRecord
  has_many :offices, dependent: :destroy
  
  validates :title, presence: true
  validates :term_length_years, presence: true, numericality: { greater_than: 0 }
end
