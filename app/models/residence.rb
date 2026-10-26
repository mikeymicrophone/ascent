class Residence < ApplicationRecord
  belongs_to :voter
  belongs_to :jurisdiction
  has_many :residence_districts, dependent: :destroy
  has_many :district_jurisdictions, through: :residence_districts, source: :jurisdiction

  validates :status, presence: true, inclusion: { in: %w[active inactive moved suspended] }
  validates :registered_at, presence: true
  validate :only_one_active_residence_per_voter

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where(status: "inactive") }
  scope :recent, -> { order(registered_at: :desc) }

  before_create :deactivate_other_residences

  def name
    "#{voter.name} - #{jurisdiction.name} (#{status})"
  end

  # Every jurisdiction whose offices are on this residence's ballot: its own and the districts it is in,
  # whether recorded or found from its location, along with every jurisdiction those sit within.
  def ballot_jurisdictions
    Jurisdiction.and_their_ancestors(
      Jurisdiction.where(id: [ jurisdiction_id, *district_jurisdiction_ids ]).or(Jurisdiction.where(id: jurisdictions_at_location.select(:id)))
    )
  end

  def covers?(race)
    ballot_jurisdictions.where(id: race.office.jurisdiction_id).exists?
  end

  # The jurisdictions just beside this one, such as the city's other wards, for pretend votes nearby.
  def neighboring_jurisdictions
    Jurisdiction.siblings_of(jurisdiction)
  end

  def activate!
    transaction do
      # Deactivate other residences for this voter
      voter.residences.where.not(id: id).update_all(status: "inactive")
      update!(status: "active")
    end
  end

  private

  def jurisdictions_at_location
    location ? Jurisdiction.covering(location.x, location.y) : Jurisdiction.none
  end

  def only_one_active_residence_per_voter
    if status == "active"
      existing_active = voter.residences.where(status: "active")
      existing_active = existing_active.where.not(id: id) if persisted?

      if existing_active.exists?
        errors.add(:status, "can only have one active residence per voter")
      end
    end
  end

  def deactivate_other_residences
    if status == "active"
      voter.residences.where(status: "active").update_all(status: "inactive")
    end
  end
end
