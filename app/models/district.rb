class District < ApplicationRecord
  include JurisdictionOwner

  # The legislative chambers a residence records a district for, by the district kinds that elect them.
  CHAMBER_KINDS = {
    "congressional" => [ "congressional district" ],
    "state_senate" => [ "state senate district" ],
    "state_house" => [ "state house district", "assembly district", "house of delegates district" ]
  }.freeze

  validates :name, :kind, presence: true

  scope :of_chamber, ->(chamber) { where(kind: CHAMBER_KINDS.fetch(chamber)) }

  def congressional?
    kind.include?("congressional")
  end

  def chamber
    CHAMBER_KINDS.find { |_, kinds| kinds.include?(kind) }&.first
  end
end
