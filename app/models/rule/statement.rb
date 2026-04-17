# frozen_string_literal: true

module Rule
  class Statement < ApplicationRecord
    enum :effect, {
      allowed: 0,
      prohibited: 1,
      conditional: 2,
      exception_limited: 3,
      unclear: 4
    }
    enum :status, { draft: 0, active: 1, archived: 2 }

    belongs_to :topic, class_name: "Rule::Topic", inverse_of: :statements
    has_many :conditions, class_name: "Rule::Condition", dependent: :destroy, inverse_of: :statement
    has_many :source_links, as: :linkable, class_name: "Rule::SourceLink", dependent: :destroy, inverse_of: :linkable

    validates :slug, presence: true, uniqueness: { scope: :topic_id }
    validates :title, presence: true
    validates :summary, presence: true
  end
end
