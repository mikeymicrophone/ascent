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
  # District 2 before District 10: shorter names first, then by name, which numbers names in order.
  scope :in_natural_order, -> { order(Arel.sql("length(districts.name), districts.name")) }
  # Districts drawn directly within a state.
  scope :in_state, ->(state) {
    state.jurisdiction ? where(id: state.jurisdiction.children.where(jurisdictionable_type: "District").select(:jurisdictionable_id)) : none
  }

  def congressional?
    kind.include?("congressional")
  end

  def chamber
    CHAMBER_KINDS.find { |_, kinds| kinds.include?(kind) }&.first
  end
end
