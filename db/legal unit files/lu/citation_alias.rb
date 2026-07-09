module LU
  class CitationAlias < ApplicationRecord
    belongs_to :unit,
      class_name: 'LU::Unit',
      inverse_of: :citation_aliases

    validates :citation, :citation_type, presence: true
    validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  end
end
