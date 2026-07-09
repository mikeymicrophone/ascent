module LU
  class Unit < ApplicationRecord
    belongs_to :edition,
      class_name: 'LU::Edition',
      inverse_of: :units

    belongs_to :parent,
      class_name: 'LU::Unit',
      optional: true,
      inverse_of: :children

    has_many :children,
      -> { order(:position, :id) },
      class_name: 'LU::Unit',
      foreign_key: :parent_id,
      dependent: :destroy,
      inverse_of: :parent

    has_many :outgoing_references,
      class_name: 'LU::Reference',
      foreign_key: :source_unit_id,
      dependent: :destroy,
      inverse_of: :source_unit

    has_many :incoming_references,
      class_name: 'LU::Reference',
      foreign_key: :target_unit_id,
      dependent: :nullify,
      inverse_of: :target_unit

    has_many :definitions,
      class_name: 'LU::Definition',
      dependent: :destroy,
      inverse_of: :unit

    has_many :projections,
      class_name: 'LU::Projection',
      dependent: :destroy,
      inverse_of: :unit

    has_many :citation_aliases,
      -> { order(:position, :id) },
      class_name: 'LU::CitationAlias',
      dependent: :destroy,
      inverse_of: :unit

    validates :official_kind, :normalized_kind, :status, presence: true
    validates :position, :depth, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    scope :roots, -> { where(parent_id: nil).order(:position, :id) }
    scope :active, -> { where(status: 'active') }
    scope :ordered, -> { order(:depth, :position, :id) }
  end
end
