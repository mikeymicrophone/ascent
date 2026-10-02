class GovernanceType < ApplicationRecord
  has_many :governing_bodies

  validates :name, presence: true
end
