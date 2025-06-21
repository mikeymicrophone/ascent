class State < ApplicationRecord
  belongs_to :country
  has_many :cities, dependent: :destroy
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :residences, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :residences
  
  scope :in_country, ->(country_id) { where(country_id: country_id) if country_id.present? }
  scope :with_election_data, -> { includes(cities: { offices: :elections }) }
  
  def active_elections_count
    cities.joins(offices: :elections).merge(Election.active).count
  end

  def total_offices_count
    offices.count + cities.joins(:offices).count
  end
end
