class Office < ApplicationRecord
  belongs_to :position
  belongs_to :jurisdiction
  belongs_to :governing_body, optional: true
  belongs_to :chamber, optional: true
  has_many :races, dependent: :destroy
  has_many :elections, through: :races

  validates :is_active, inclusion: { in: [ true, false ] }
  validate :chamber_matches_governing_body
  validate :race_elections_match_jurisdiction, if: :will_save_change_to_jurisdiction_id?

  before_validation :assign_governing_body_from_chamber

  scope :active, -> { where(is_active: true) }
  scope :with_elections_and_candidates, -> { includes(:position, races: :candidates) }
  scope :with_election_details, -> { includes(races: [ :candidacies, :election ]) }

  def name
    position.title + " - " + jurisdiction.name
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
    if jurisdiction && races.joins(:election).where.not(elections: { jurisdiction_id: jurisdiction_id }).exists?
      errors.add(:jurisdiction, 'must match the elections of its races')
    end
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
