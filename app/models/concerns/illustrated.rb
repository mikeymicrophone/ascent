module Illustrated
  extend ActiveSupport::Concern

  included do
    has_many :image_placements, -> { order(:position, :id) }, as: :subject, dependent: :destroy, inverse_of: :subject
    has_many :images, through: :image_placements

    accepts_nested_attributes_for :image_placements, allow_destroy: true, reject_if: ->(attributes) {
      attributes["id"].blank? && attributes["image_id"].blank? && attributes.fetch("image_attributes", {}).values.all?(&:blank?)
    }
  end
end
