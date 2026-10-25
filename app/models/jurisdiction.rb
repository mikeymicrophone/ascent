class Jurisdiction < ApplicationRecord
  belongs_to :jurisdictionable, polymorphic: true
  belongs_to :parent, class_name: "Jurisdiction", optional: true
  has_many :children, class_name: "Jurisdiction", foreign_key: :parent_id, inverse_of: :parent, dependent: :restrict_with_error
  has_many :boundaries, class_name: "JurisdictionBoundary", dependent: :destroy
  has_many :offices, dependent: :restrict_with_error
  has_many :elections, dependent: :restrict_with_error
  has_many :residences, dependent: :restrict_with_error
  has_many :governing_bodies, dependent: :restrict_with_error

  validates :jurisdictionable_id, uniqueness: { scope: :jurisdictionable_type }
  validate :parent_does_not_create_cycle

  delegate :name, to: :jurisdictionable

  scope :covering, ->(longitude, latitude, on: Date.current) {
    joins(:boundaries).merge(JurisdictionBoundary.effective_on(on))
      .where("ST_Covers(jurisdiction_boundaries.geometry, ST_SetSRID(ST_MakePoint(?, ?), 4326))", longitude, latitude)
      .distinct
  }

  # This jurisdiction, or one nested anywhere within it.
  def contains?(jurisdiction)
    self_and_descendants.where(id: jurisdiction.id).exists?
  end

  def self_and_descendants
    self.class.with_recursive(jurisdiction_tree: [
      self.class.where(id: id),
      self.class.joins("INNER JOIN jurisdiction_tree ON jurisdictions.parent_id = jurisdiction_tree.id")
    ]).from("jurisdiction_tree AS jurisdictions")
  end

  private

  def parent_does_not_create_cycle
    ancestor = parent
    seen = Set.new([ self ])
    while ancestor
      if seen.include?(ancestor)
        errors.add(:parent, "must not create a cycle")
        return
      end
      seen.add(ancestor)
      ancestor = ancestor.parent
    end
  end
end
