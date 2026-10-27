# Where a stance comes from: a communication, with a short quote or a moment in a video.
class StanceEvidence < ApplicationRecord
  RELATIONS = %w[states clarifies contradicts].freeze
  # Provisional, until the quote-length decision in doc/communications_plan.md is settled.
  QUOTE_LIMIT = 300

  belongs_to :stance
  belongs_to :communication

  validates :relation, inclusion: { in: RELATIONS }
  validates :quote, length: { maximum: QUOTE_LIMIT }
  validates :offset_seconds, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :communication_id, uniqueness: { scope: :stance_id }

  # "1:42" or "1:02:05", for a moment in a video.
  def timestamp
    return unless offset_seconds

    hours, remainder = offset_seconds.divmod(3600)
    minutes, seconds = remainder.divmod(60)
    hours.positive? ? format("%d:%02d:%02d", hours, minutes, seconds) : format("%d:%02d", minutes, seconds)
  end
end
