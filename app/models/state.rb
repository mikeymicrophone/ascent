class State < ApplicationRecord
  include JurisdictionOwner

  belongs_to :country
  has_many :counties, dependent: :destroy
  has_many :municipalities, dependent: :destroy
  has_many :parties, dependent: :destroy

  scope :in_country, ->(country_id) { where(country_id: country_id) if country_id.present? }
  scope :with_election_data, -> { includes(:jurisdiction, municipalities: { jurisdiction: :elections }) }
end
