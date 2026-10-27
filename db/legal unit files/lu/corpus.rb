module LU
  class Corpus < ApplicationRecord
    has_many :editions,
      class_name: 'LU::Edition',
      dependent: :destroy,
      inverse_of: :corpus

    validates :name, :slug, :jurisdiction, :publication_kind, presence: true
    validates :slug, uniqueness: { scope: :jurisdiction }
  end
end
