module LU
  class Projection < ApplicationRecord
    belongs_to :unit,
      class_name: 'LU::Unit',
      inverse_of: :projections

    validates :projection_type, :format, presence: true
  end
end
