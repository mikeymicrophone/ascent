# Support for a candidacy. Ballot-line endorsements follow their printed party line;
# other kinds are entered independently and are never changed by a seed refresh.
class Endorsement < ApplicationRecord
  KINDS = %w[ballot_line public].freeze
  ENDORSER_TYPES = %w[Party Person].freeze

  belongs_to :candidacy
  belongs_to :endorser, polymorphic: true
  belongs_to :ballot_line, optional: true

  validates :kind, inclusion: { in: KINDS }
  validates :endorser_type, inclusion: { in: ENDORSER_TYPES }
  validates :strength, numericality: { only_integer: true, in: 1..5 }, allow_nil: true
  validates :ballot_line, presence: true, if: -> { kind == "ballot_line" }
  validates :endorser_id, uniqueness: { scope: [ :candidacy_id, :endorser_type, :kind ] }

  scope :current, -> { where(withdrawn_on: nil) }
end
