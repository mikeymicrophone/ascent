class Residence < ApplicationRecord
  belongs_to :voter
  # Where someone lives: a town, or the county outside any town.
  belongs_to :jurisdiction
  # The areas the town alone can't tell, when known: its county, since a city can span several, and
  # the District jurisdiction of each chamber.
  belongs_to :county, class_name: "Jurisdiction", optional: true
  belongs_to :congressional_district, class_name: "Jurisdiction", optional: true
  belongs_to :state_senate_district, class_name: "Jurisdiction", optional: true
  belongs_to :state_house_district, class_name: "Jurisdiction", optional: true

  DISTRICT_SLOTS = { "congressional" => :congressional_district, "state_senate" => :state_senate_district,
                     "state_house" => :state_house_district }.freeze
  AREA_SLOTS = { "county" => :county, **DISTRICT_SLOTS }.freeze

  validates :status, presence: true, inclusion: { in: %w[active inactive moved suspended] }
  validates :registered_at, :started_on, presence: true
  validate :ends_after_it_starts
  validate :districts_fit_their_slots
  validate :county_is_a_county

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :recent, -> { order(registered_at: :desc) }
  # A voter can live in several places at once; each open-ended, active residence is current.
  scope :current, -> { active.where(ended_on: nil) }
  scope :past, -> { where.not(ended_on: nil) }
  scope :chronological, -> { order(started_on: :desc) }
  # Residences lived in at any point between two dates.
  scope :lived_in_between, ->(from, to) { where(started_on: ..to).where("residences.ended_on IS NULL OR residences.ended_on >= ?", from) }

  def name
    "#{voter.name} - #{jurisdiction.name} (#{status})"
  end

  # Every jurisdiction whose offices are on this residence's ballot: its town, county and districts,
  # and every jurisdiction those sit within.
  def ballot_jurisdictions
    Jurisdiction.and_their_ancestors(Jurisdiction.where(id: [ jurisdiction_id, *area_ids ].compact))
  end

  def area_ids
    AREA_SLOTS.values.map { public_send("#{it}_id") }
  end

  def districts
    [ congressional_district, state_senate_district, state_house_district ].compact
  end

  # Where the town sits, for showing beside its name: the place it nests in, and its county when that's
  # another place, as Kings County is for Brooklyn under New York City.
  def surroundings
    [ jurisdiction.parent, county ].compact.uniq - [ jurisdiction ]
  end

  def covers?(race)
    ballot_jurisdictions.where(id: race.office.jurisdiction_id).exists?
  end

  # The jurisdictions just beside this one, such as the city's other wards, for pretend votes nearby.
  def neighboring_jurisdictions
    Jurisdiction.siblings_of(jurisdiction)
  end

  # Every jurisdiction whose offices are on the ballot for these residences together.
  def self.ballot_jurisdictions(residences)
    ids = residences.pluck(:jurisdiction_id, *AREA_SLOTS.values.map { "#{it}_id" }).flatten.compact
    Jurisdiction.and_their_ancestors(Jurisdiction.where(id: ids))
  end

  def current?
    status == "active" && ended_on.nil?
  end

  def move_out!(on: Date.current)
    update!(status: "moved", ended_on: on)
  end

  private

  def ends_after_it_starts
    errors.add(:ended_on, "must be on or after the date it starts") if started_on && ended_on && ended_on < started_on
  end

  # A district slot holds only a district of its own chamber.
  def districts_fit_their_slots
    DISTRICT_SLOTS.each do |chamber, slot|
      district = public_send(slot)
      errors.add(slot, "must be a #{chamber.humanize(capitalize: false)} district") if district && district.jurisdictionable.try(:chamber) != chamber
    end
  end

  def county_is_a_county
    errors.add(:county, "must be a county") if county && county.jurisdictionable_type != "County"
  end
end
