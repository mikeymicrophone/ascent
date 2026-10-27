class Chamber < ApplicationRecord
  belongs_to :governing_body
  has_many :offices, dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :governing_body_id }
end
