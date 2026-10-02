class Office < ApplicationRecord
  belongs_to :position
  belongs_to :jurisdiction, polymorphic: true
  belongs_to :governing_body, optional: true
  belongs_to :chamber, optional: true
  has_many :elections, dependent: :destroy

  validates :is_active, inclusion: { in: [ true, false ] }
  validate :chamber_matches_governing_body

  before_validation :assign_governing_body_from_chamber

  scope :active, -> { where(is_active: true) }
  scope :with_elections_and_candidates, -> { includes(:position, elections: :candidates) }
  scope :with_election_details, -> { includes(elections: [ :candidacies, :office ]) }

  def name
    position.title + " - " + jurisdiction.name
  end

  def recent_election
    elections.completed.recent.first
  end

  def current_office_holder
    recent_election&.approval_winner
  end

  def branch
    return governing_body.branch if governing_body

    position.branch
  end

  private

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
