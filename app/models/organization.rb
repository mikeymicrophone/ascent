# An institution that endorses or nominates candidacies: a party, a union, an advocacy group, a
# newspaper. A nonpartisan primary's nomination comes from a placeholder Organization standing for
# that primary, such as California's top-two primary.
class Organization < ApplicationRecord
  KINDS = %w[union advocacy business media civic nonpartisan_primary other].freeze

  belongs_to :state, optional: true
  has_many :endorsements, as: :endorser, dependent: :destroy
  has_many :nominations, class_name: "Office", foreign_key: :nominating_organization_id, dependent: :restrict_with_error, inverse_of: :nominating_organization

  validates :name, presence: true, uniqueness: { scope: :state_id }
  validates :kind, inclusion: { in: KINDS }, unless: -> { is_a?(Party) }

  scope :named_like, ->(query) {
    pattern = "%#{sanitize_sql_like(query.strip)}%"
    where("organizations.name ILIKE :pattern OR organizations.abbreviation ILIKE :pattern", pattern: pattern)
  }
end
