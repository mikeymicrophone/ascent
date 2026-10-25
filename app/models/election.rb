class Election < ApplicationRecord
  # Elections that decide nominations rather than offices.
  PRIMARY_KINDS = %w[primary primary_runoff].freeze

  belongs_to :jurisdiction
  belongs_to :year
  has_many :races, dependent: :destroy
  has_many :offices, through: :races
  has_many :candidacies, through: :races
  has_many :candidates, through: :candidacies, source: :person

  validates :name, :election_date, presence: true
  validates :status, presence: true, inclusion: { in: %w[upcoming active completed cancelled] }
  validates :is_mock, :is_historical, inclusion: { in: [ true, false ] }
  validate :early_voting_dates_are_ordered
  validate :race_offices_match_jurisdiction, if: :will_save_change_to_jurisdiction_id?

  scope :upcoming, -> { where(status: "upcoming") }
  scope :active, -> { where(status: "active") }
  scope :completed, -> { where(status: "completed") }
  scope :mock, -> { where(is_mock: true) }
  scope :historical, -> { where(is_historical: true) }
  scope :real, -> { where(is_mock: false, is_historical: false) }
  scope :recent, -> { order(election_date: :desc) }
  scope :primaries, -> { where(kind: PRIMARY_KINDS) }
  scope :with_full_details, -> { includes(:jurisdiction, races: [ :office, :candidates, :candidacies ]) }
  scope :with_candidacy_details, -> { includes(races: { candidacies: [ :person, :ratings ] }) }

  private

  def race_offices_match_jurisdiction
    if jurisdiction && races.joins(:office).where.not(offices: { jurisdiction_id: jurisdiction.self_and_descendants.select(:id) }).exists?
      errors.add(:jurisdiction, "must contain the offices of its races")
    end
  end

  def early_voting_dates_are_ordered
    if early_voting_starts_on && early_voting_ends_on && early_voting_starts_on > early_voting_ends_on
      errors.add(:early_voting_ends_on, "must be on or after early voting starts")
    end
    return unless election_date

    [ :early_voting_starts_on, :early_voting_ends_on ].each do |attribute|
      if self[attribute] && self[attribute] > election_date
        errors.add(attribute, "must be on or before election day")
      end
    end
  end
end
