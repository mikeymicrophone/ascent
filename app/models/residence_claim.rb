# A voter saying where they live, or used to live: a town (or the county, outside any town) and the
# House, state senate and state assembly districts it sits in, with dates for a past residence.
#
# A location is used once, never kept: it finds the smallest town and the district of each chamber
# whose boundaries cover it. A searched town fills in each district it lies wholly inside; where the
# town is split, the voter picks from the districts it overlaps, or from the state's when no boundaries
# are mapped.
class ResidenceClaim
  include ActiveModel::Model
  include ActiveModel::Attributes

  CHAMBERS = Residence::DISTRICT_SLOTS.keys.freeze
  CHAMBER_LABELS = { "congressional" => "U.S. House district", "state_senate" => "State senate district",
                     "state_house" => "State assembly district" }.freeze

  attribute :latitude, :float
  attribute :longitude, :float
  attribute :jurisdiction_id, :integer
  attribute :congressional_district_id, :integer
  attribute :state_senate_district_id, :integer
  attribute :state_house_district_id, :integer
  attribute :started_on, :date
  attribute :ended_on, :date
  attribute :past, :boolean, default: false
  # Whether the voter moved here, ending the other places they live, or lives here as well.
  attribute :moving, :boolean, default: true
  attr_accessor :voter

  validates :latitude, numericality: { in: -90..90 }, if: :from_location?
  validates :longitude, numericality: { in: -180..180 }, if: :from_location?
  validates :started_on, :ended_on, presence: true, if: :past
  validate :town_found
  validate :dates_in_order

  def from_location?
    latitude.present? && longitude.present?
  end

  # The jurisdictions whose boundaries cover the location, today.
  def covering
    @covering ||= from_location? ? Jurisdiction.covering(longitude, latitude).includes(:jurisdictionable).to_a : []
  end

  # The town: the smallest one the location falls in, else its county, else its state; or the one chosen.
  def town
    @town ||= from_location? ? smallest_covering : Jurisdiction.find_by(id: jurisdiction_id)
  end

  # The district of a chamber: the voter's pick, else the one the location falls in, else the only one
  # the town overlaps.
  def district(chamber)
    picked(chamber) || covering.find { it.jurisdictionable.try(:chamber) == chamber } || sole_overlap(chamber)
  end

  def districts
    CHAMBERS.index_with { district(it) }
  end

  # The districts to pick from when the town alone doesn't settle the chamber.
  def district_choices(chamber)
    overlapping(chamber).presence || state_districts(chamber)
  end

  def needs_pick?(chamber)
    district(chamber).nil? && district_choices(chamber).any?
  end

  def ballot_jurisdictions
    Jurisdiction.and_their_ancestors(Jurisdiction.where(id: [ town, *districts.values ].compact.map(&:id)))
  end

  def open_races
    Race.real.open_to_rating.in_jurisdictions(ballot_jurisdictions)
  end

  # Open races by ballot level, city first, for showing what the voter would see.
  def open_race_counts
    open_races.includes(office: :jurisdiction).group_by { it.office.jurisdiction.ballot_level }.transform_values(&:size)
      .sort_by { |level, _| Jurisdiction::BALLOT_LEVELS.index(level) }.to_h
  end

  def save!
    validate!
    if past
      voter.add_past_residence!(town, started_on: started_on, ended_on: ended_on, districts: districts)
    else
      voter.claim_residence!(town, districts: districts, moving: moving)
    end
  end

  private

  def smallest_covering
    %w[Municipality County State].lazy.filter_map { |type| smallest(covering.select { it.jurisdictionable_type == type }) }.first
  end

  def smallest(jurisdictions)
    return jurisdictions.first if jurisdictions.size < 2

    JurisdictionBoundary.effective_on(Date.current).where(jurisdiction: jurisdictions).order(Arel.sql("ST_Area(geometry)")).first&.jurisdiction
  end

  def picked(chamber)
    id = public_send("#{chamber}_district_id")
    Jurisdiction.districts_of_chamber(chamber).find_by(id: id) if id
  end

  def overlapping(chamber)
    town ? Jurisdiction.districts_of_chamber(chamber).overlapping(town).includes(:jurisdictionable).to_a : []
  end

  def sole_overlap(chamber)
    choices = overlapping(chamber)
    choices.first if choices.one?
  end

  def state_districts(chamber)
    state = town&.self_and_ancestors&.find_by(jurisdictionable_type: "State")
    state ? Jurisdiction.districts_of_chamber(chamber).where(parent: state).includes(:jurisdictionable).sort_by { it.name.to_s }.to_a : []
  end

  def town_found
    errors.add(:base, "We couldn't place that location yet. Search for your city or town instead.") unless town
  end

  def dates_in_order
    errors.add(:ended_on, "must be on or after the date you moved in") if started_on && ended_on && ended_on < started_on
  end
end
