module LU
  class Edition < ApplicationRecord
    belongs_to :corpus,
      class_name: 'LU::Corpus',
      inverse_of: :editions

    has_many :units,
      class_name: 'LU::Unit',
      dependent: :destroy,
      inverse_of: :edition

    has_many :references,
      class_name: 'LU::Reference',
      dependent: :destroy,
      inverse_of: :edition

    validates :label, presence: true
  end
end
