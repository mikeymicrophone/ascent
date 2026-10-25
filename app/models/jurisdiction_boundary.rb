class JurisdictionBoundary < ApplicationRecord
  belongs_to :jurisdiction

  validates :geometry, :valid_from, presence: true
  validate :geometry_is_a_valid_boundary
  validate :effective_period_is_valid
  validate :effective_period_does_not_overlap

  scope :effective_on, ->(date) { where("valid_from <= ? AND (valid_until IS NULL OR valid_until > ?)", date, date) }

  private

  def geometry_is_a_valid_boundary
    return unless geometry

    unless RGeo::Feature::MultiPolygon.check_type(geometry) && geometry.srid == 4326 && !geometry.empty? && geometry.valid?
      errors.add(:geometry, "must be a valid, nonempty MultiPolygon in SRID 4326")
    end
  end

  def effective_period_is_valid
    if valid_from && valid_until && valid_until <= valid_from
      errors.add(:valid_until, "must be after the start date")
    end
  end

  def effective_period_does_not_overlap
    return unless jurisdiction && valid_from

    overlapping = jurisdiction.boundaries.where.not(id: id)
      .where("valid_until IS NULL OR valid_until > ?", valid_from)
    overlapping = overlapping.where("valid_from < ?", valid_until) if valid_until
    errors.add(:valid_from, "overlaps an existing boundary period") if overlapping.exists?
  end
end
