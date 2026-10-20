class Municipality < ApplicationRecord
  include JurisdictionOwner

  belongs_to :state
  belongs_to :county, optional: true

  validates :name, presence: true
  validate :county_matches_state

  scope :in_state, ->(state) { where(state: state) if state.present? }
  scope :with_office_data, -> { includes(:state, jurisdiction: :offices) }

  private

  def county_matches_state
    errors.add(:county, 'must belong to the same state') if county && county.state != state
  end
end
