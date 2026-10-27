class Office < ApplicationRecord
  belongs_to :position
  belongs_to :jurisdiction
  belongs_to :governing_body, optional: true
  belongs_to :chamber, optional: true
  # A nomination is an Office too: the organization's place on the general ballot for another office.
  belongs_to :nominee_for, class_name: "Office", foreign_key: :nominee_for_office_id, optional: true, inverse_of: :nominations
  belongs_to :nominating_organization, class_name: "Organization", optional: true, inverse_of: :nominations
  has_many :nominations, class_name: "Office", foreign_key: :nominee_for_office_id, dependent: :destroy, inverse_of: :nominee_for
  has_many :races, dependent: :destroy
  has_many :elections, through: :races

  validates :is_active, inclusion: { in: [ true, false ] }
  validate :chamber_matches_governing_body
  validate :nomination_is_complete
  validates :nominee_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :race_elections_match_jurisdiction, if: :will_save_change_to_jurisdiction_id?

  before_validation :assign_governing_body_from_chamber

  scope :active, -> { where(is_active: true) }
  scope :nominations, -> { where.not(nominee_for_office_id: nil) }
  scope :with_elections_and_candidates, -> { includes(:position, races: :candidates) }
  scope :with_election_details, -> { includes(races: [ :candidacies, :election ]) }

  def name
    return "#{nominating_organization.name} nominee for #{nominee_for.name}" if nomination?

    position.title + " - " + jurisdiction.name
  end

  # The seat's code as words: DISTRICT_10 reads "District 10", AT_LARGE "At large".
  def seat_label
    seat_code&.humanize
  end

  def nomination?
    nominee_for_office_id.present?
  end

  def recent_race
    races.completed.recent.first
  end

  def current_office_holder
    recent_race&.approval_winner
  end

  def branch
    return governing_body.branch if governing_body

    position.branch
  end

  private

  def race_elections_match_jurisdiction
    if jurisdiction && races.includes(election: :jurisdiction).any? { !it.election.jurisdiction.contains?(jurisdiction) }
      errors.add(:jurisdiction, "must be within the elections of its races")
    end
  end

  # A nomination is decided in the office's own jurisdiction, under the Nominee position.
  def nomination_is_complete
    return unless nomination? || nominating_organization || nominee_count

    errors.add(:nominee_for, "is required for a nomination") unless nominee_for
    errors.add(:nominating_organization, "is required for a nomination") unless nominating_organization
    errors.add(:nominee_count, "is required for a nomination") unless nominee_count
    errors.add(:position, "must be #{Position::NOMINEE_TITLE} for a nomination") unless position&.title == Position::NOMINEE_TITLE
    errors.add(:jurisdiction, "must be the nominated office's") if nominee_for && jurisdiction_id != nominee_for.jurisdiction_id
    errors.add(:nominee_for, "cannot itself be a nomination") if nominee_for&.nomination?
  end

    def assign_governing_body_from_chamber
    return if chamber.blank? || governing_body.present?

    self.governing_body = chamber.governing_body
  end

  def chamber_matches_governing_body
    return if chamber.blank? || governing_body.blank?
    return if chamber.governing_body_id == governing_body_id

    errors.add(:chamber, "must belong to the governing body")
  end
end
