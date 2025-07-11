class GovernanceType < ApplicationRecord
  has_many :governing_bodies

  enum :authority_level, {
    local: 0,
    regional: 1,
    state: 2,
    federal: 3
  }

  validates :name, presence: true
  validates :authority_level, presence: true
end
