module JurisdictionOwner
  extend ActiveSupport::Concern

  included do
    has_one :jurisdiction, as: :jurisdictionable, dependent: :destroy
    has_many :offices, through: :jurisdiction
    has_many :elections, through: :jurisdiction
    has_many :active_elections, -> { active }, through: :jurisdiction, source: :elections
    has_many :residences, through: :jurisdiction
    has_many :voters, through: :residences
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
