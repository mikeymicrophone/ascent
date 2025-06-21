class Country < ApplicationRecord
  has_many :states, dependent: :destroy
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :residences, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :residences
  
  scope :with_election_stats, -> { 
    includes(states: { cities: { offices: :elections } })
  }
  
  def active_elections_count
    states.joins(cities: { offices: :elections }).merge(Election.active).count
  end

  def total_offices_count
    offices.count + 
    states.joins(:offices).count + 
    states.joins(cities: :offices).count
  end
end
