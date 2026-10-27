# frozen_string_literal: true

module Rule
  class Topic < ApplicationRecord
    enum :status, { draft: 0, active: 1, archived: 2 }

    has_many :statements, class_name: "Rule::Statement", dependent: :destroy, inverse_of: :topic

    validates :slug, presence: true, uniqueness: true
    validates :title, presence: true
  end
end
