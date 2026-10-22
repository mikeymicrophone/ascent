class Policy < ApplicationRecord
  belongs_to :governing_body
  belongs_to :area_of_concern
  belongs_to :approach
  has_many :official_codes

  # The status column stores these words, so the enum maps each value to itself.
  enum :status, { pending: "pending", enacted: "enacted", repealed: "repealed" }, validate: true

  alias_attribute :name, :title

  scope :by_governing_body, ->(governing_body_id) { where(governing_body_id: governing_body_id) if governing_body_id.present? }
end
