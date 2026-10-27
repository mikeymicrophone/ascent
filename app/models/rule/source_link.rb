# frozen_string_literal: true

module Rule
  class SourceLink < ApplicationRecord
    enum :relationship_kind, {
      primary_support: 0,
      secondary_support: 1,
      cross_reference: 2,
      caution_source: 3
    }

    belongs_to :linkable, polymorphic: true, inverse_of: :source_links

    validates :lu_unit_id, presence: true
  end
end
