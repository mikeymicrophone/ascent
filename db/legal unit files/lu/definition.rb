module LU
  class Definition < ApplicationRecord
    belongs_to :unit,
      class_name: 'LU::Unit',
      inverse_of: :definitions

    belongs_to :defined_unit,
      class_name: 'LU::Unit',
      optional: true

    validates :term, :scope_type, presence: true
  end
end
