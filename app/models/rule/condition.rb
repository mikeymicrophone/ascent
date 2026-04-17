# frozen_string_literal: true

module Rule
  class Condition < ApplicationRecord
    enum :kind, { required: 0, clarifying: 1, disqualifying: 2 }

    belongs_to :statement, class_name: "Rule::Statement", inverse_of: :conditions
    has_many :source_links, as: :linkable, class_name: "Rule::SourceLink", dependent: :destroy, inverse_of: :linkable

    validates :slug, presence: true, uniqueness: { scope: :statement_id }
    validates :label, presence: true
  end
end
