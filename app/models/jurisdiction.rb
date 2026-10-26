class Jurisdiction < ApplicationRecord
  belongs_to :jurisdictionable, polymorphic: true
  belongs_to :parent, class_name: "Jurisdiction", optional: true
  has_many :children, class_name: "Jurisdiction", foreign_key: :parent_id, inverse_of: :parent, dependent: :restrict_with_error
  has_many :boundaries, class_name: "JurisdictionBoundary", dependent: :destroy
  has_many :offices, dependent: :restrict_with_error
  has_many :elections, dependent: :restrict_with_error
  has_many :residences, dependent: :restrict_with_error
  has_many :governing_bodies, dependent: :restrict_with_error

  # The ballot sections, from the most local; a jurisdiction's offices appear under one of them.
  BALLOT_LEVELS = %w[city county state federal].freeze

  # The places a search can name, by the type stored in jurisdictionable_type.
  NAMED_TYPES = %w[Municipality County State District Country].freeze

  validates :jurisdictionable_id, uniqueness: { scope: :jurisdictionable_type }
  validate :parent_does_not_create_cycle

  delegate :name, to: :jurisdictionable

  scope :covering, ->(longitude, latitude, on: Date.current) {
    joins(:boundaries).merge(JurisdictionBoundary.effective_on(on))
      .where("ST_Covers(jurisdiction_boundaries.geometry, ST_SetSRID(ST_MakePoint(?, ?), 4326))", longitude, latitude)
      .distinct
  }

  # The given jurisdictions and every one they sit within, up to their countries.
  scope :and_their_ancestors, ->(jurisdictions) {
    with_recursive(jurisdiction_chain: [
      where(id: jurisdictions),
      joins("INNER JOIN jurisdiction_chain ON jurisdictions.id = jurisdiction_chain.parent_id")
    ]).from("jurisdiction_chain AS jurisdictions").distinct
  }

  # The given jurisdictions and every one nested anywhere within them.
  scope :and_their_descendants, ->(jurisdictions) {
    with_recursive(jurisdiction_tree: [
      where(id: jurisdictions),
      joins("INNER JOIN jurisdiction_tree ON jurisdictions.parent_id = jurisdiction_tree.id")
    ]).from("jurisdiction_tree AS jurisdictions").distinct
  }

  # Jurisdictions sharing a parent with the given one, such as the other wards of its city.
  scope :siblings_of, ->(jurisdiction) { where(parent_id: jurisdiction.parent_id).where.not(id: jurisdiction.id) }

  scope :named_like, ->(query) {
    pattern = "%#{sanitize_sql_like(query.strip)}%"
    NAMED_TYPES.map { |type| where(jurisdictionable_type: type, jurisdictionable_id: type.constantize.where("name ILIKE ?", pattern).select(:id)) }
      .reduce(:or)
  }

  # This jurisdiction, or one nested anywhere within it.
  def contains?(jurisdiction)
    self_and_descendants.where(id: jurisdiction.id).exists?
  end

  def self_and_ancestors
    self.class.and_their_ancestors(self)
  end

  # Where this jurisdiction's offices sit on a ballot: a district goes with the jurisdiction it
  # belongs to, except that congressional districts are federal.
  def ballot_level
    case jurisdictionable
    when Country then "federal"
    when State then "state"
    when County then "county"
    when Municipality then "city"
    when District then jurisdictionable.congressional? ? "federal" : parent&.ballot_level || "city"
    end
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
