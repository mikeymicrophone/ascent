# One line a candidate is printed on, with the label exactly as the official source prints it.
class BallotLine < ApplicationRecord
  KINDS = %w[party designation petition write_in unclassified].freeze

  belongs_to :candidacy
  belongs_to :party, optional: true
  has_one :endorsement, dependent: :destroy

  validates :label, presence: true, uniqueness: { scope: :candidacy_id }
  validates :kind, inclusion: { in: KINDS }
  validate :party_matches_kind

  after_save :sync_party_endorsement

  scope :printed_order, -> { order(:position, :id) }

  private

  def party_matches_kind
    errors.add(:party, "is only set on party lines") if party && kind != "party"
  end

  # A party's line is also that party's endorsement of the candidacy.
  def sync_party_endorsement
    if party
      record = endorsement || build_endorsement(candidacy: candidacy, kind: "ballot_line")
      record.update!(endorser: party)
    else
      endorsement&.destroy!
    end
  end
end
