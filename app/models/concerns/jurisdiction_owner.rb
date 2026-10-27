module JurisdictionOwner
  extend ActiveSupport::Concern

  included do
    has_one :jurisdiction, as: :jurisdictionable, dependent: :destroy
    has_many :offices, through: :jurisdiction
    has_many :elections, through: :jurisdiction
    has_many :active_elections, -> { active }, through: :jurisdiction, source: :elections
    has_many :residences, through: :jurisdiction
    has_many :voters, through: :residences

    # Matching a place by name, as a boundary import does, ignoring letter case.
    scope :named, ->(*names) { where("lower(#{table_name}.name) IN (?)", names.flatten.map(&:downcase)) }
    # Places whose name contains a search, as a list's search box finds them.
    scope :named_like, ->(query) { where("#{table_name}.name ILIKE ?", "%#{sanitize_sql_like(query.strip)}%") }
  end

  # The jurisdictions whose offices and elections belong to this place's own page: itself, unless a place
  # also decides its wards or districts, as a city does.
  def local_jurisdictions
    jurisdiction ? Jurisdiction.where(id: jurisdiction.id) : Jurisdiction.none
  end

  # The open real races decided here, soonest election first.
  def open_local_races
    Race.real.open_to_rating.in_jurisdictions(local_jurisdictions).recent.reorder("elections.election_date")
  end

  # Open real races decided by the places within this one, counted by the kind of place, such as
  # { "Municipality" => 1203, "County" => 88 }.
  def open_races_within
    return {} unless jurisdiction

    Race.real.open_to_rating.joins(office: :jurisdiction)
      .where(offices: { jurisdiction_id: jurisdiction.self_and_descendants.select(:id) })
      .where.not(offices: { jurisdiction_id: local_jurisdictions.select(:id) })
      .group("jurisdictions.jurisdictionable_type").count
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

  def active_elections_count
    return 0 unless jurisdiction

    Election.active.where(jurisdiction_id: jurisdiction.self_and_descendants.select(:id)).count
  end

  def total_offices_count
    return 0 unless jurisdiction

    Office.where(jurisdiction_id: jurisdiction.self_and_descendants.select(:id)).count
  end
end
