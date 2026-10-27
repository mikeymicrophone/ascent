module LU
  class Reference < ApplicationRecord
    belongs_to :edition,
      class_name: 'LU::Edition',
      inverse_of: :references

    belongs_to :source_unit,
      class_name: 'LU::Unit',
      inverse_of: :outgoing_references

    belongs_to :target_unit,
      class_name: 'LU::Unit',
      optional: true,
      inverse_of: :incoming_references

    validates :raw_citation, :reference_type, presence: true

    scope :unresolved, -> { where(target_unit_id: nil) }
  end
end
