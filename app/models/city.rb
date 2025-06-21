class City < ApplicationRecord
  belongs_to :state
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :residences, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :residences
  has_many :elections, through: :offices
  has_many :active_elections, -> { merge Election.active }, through: :offices, source: :elections
  
  scope :in_state, ->(state) { where(state: state) if state.present? }
  scope :with_office_data, -> { includes(:state, offices: :elections) }
end
