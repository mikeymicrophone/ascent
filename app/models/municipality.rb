class Municipality < ApplicationRecord
  include JurisdictionOwner
  include Engageable

  belongs_to :state
  belongs_to :county, optional: true

  validates :name, presence: true
  validate :county_matches_state

  scope :in_state, ->(state) { where(state: state) if state.present? }
  scope :with_office_data, -> { includes(:state, jurisdiction: :offices) }

  # The county, unless it is the city itself, as with Virginia's independent cities.
  def distinct_county
    county unless county&.name&.start_with?(name)
  end

  # The jurisdictions decided here: the city and the wards and districts within it.
  def local_jurisdictions
    jurisdiction ? Jurisdiction.and_their_descendants(jurisdiction) : Jurisdiction.none
  end

  # The open real races decided here, soonest election first.
  def open_local_races
    Race.real.open_to_rating.in_jurisdictions(local_jurisdictions).recent.reorder("elections.election_date")
  end

  # The open real races every resident also votes in, decided by the county, state or country above.
  def open_races_above
    return Race.none unless jurisdiction

    Race.real.open_to_rating.in_jurisdictions(Jurisdiction.and_their_ancestors(jurisdiction.parent_id ? jurisdiction.parent : jurisdiction))
      .where.not(id: open_local_races.select(:id))
  end

  def next_election
    Election.where(id: open_local_races.select(:election_id)).order(:election_date).first
  end

  def upcoming_elections
    Election.in_jurisdictions(local_jurisdictions).open_to_rating.order(:election_date)
  end

  def past_elections
    Election.in_jurisdictions(local_jurisdictions).completed.recent
  end

  # Seats elected here by position, most seats first, such as { "Member City Council" => 11 }.
  def office_seats
    jurisdiction ? jurisdiction.offices.active.joins(:position).group("positions.title").order(count_all: :desc, "positions.title": :asc).count : {}
  end

  # The other municipalities in the same county, for moving along the map.
  def neighbors
    county ? county.municipalities.where.not(id: id).order(:name) : Municipality.none
  end

  private

  def county_matches_state
    errors.add(:county, "must belong to the same state") if county && county.state != state
  end
end
