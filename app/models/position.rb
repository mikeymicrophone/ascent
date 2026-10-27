class Position < ApplicationRecord
  include GovernmentBranch
  include Titled

  # The position of every nomination office: a place on a general ballot that a primary decides.
  NOMINEE_TITLE = "Nominee".freeze

  has_many :offices, dependent: :destroy

  validates :title, presence: true
  # Left blank when the term varies by state or the source does not state it.
  validates :term_length_years, numericality: { greater_than: 0 }, allow_nil: true
end
