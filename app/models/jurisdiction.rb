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

  # Jurisdictions whose boundary shares more than a sliver of the given jurisdiction's area today, such
  # as the districts a town falls in; shared edges and digitizing slivers don't count.
  scope :overlapping, ->(jurisdiction, at_least: 0.001, on: Date.current) {
    town = JurisdictionBoundary.effective_on(on).where(jurisdiction_id: jurisdiction.id).select(:geometry).limit(1).to_sql
    joins(:boundaries).merge(JurisdictionBoundary.effective_on(on))
      .where("ST_Area(ST_Intersection(jurisdiction_boundaries.geometry, (#{town}))) > ? * ST_Area((#{town}))", at_least)
      .distinct
  }

  # The district jurisdictions that elect one chamber: congressional, state_senate or state_house.
  scope :districts_of_chamber, ->(chamber) { where(jurisdictionable_type: "District", jurisdictionable_id: District.of_chamber(chamber).select(:id)) }

  # The jurisdiction a TIGER/Line feature describes, by its feature class and GEOID.
  scope :with_census_id, ->(census_class, geoid) { where(census_class: census_class, census_geoid: geoid) }

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

  # What kind of place this is and where, for telling same-named places apart:
  # "City or town · Onondaga County, New York".
  def place_description
    owner = jurisdictionable
    kind = { "Municipality" => "City or town", "County" => "County" }.fetch(jurisdictionable_type, owner.model_name.human)
    where = [ (owner.county&.name if owner.respond_to?(:county)), (owner.state&.name if owner.respond_to?(:state)) ].compact.join(", ")
    [ kind, where.presence ].compact.join(" · ")
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
