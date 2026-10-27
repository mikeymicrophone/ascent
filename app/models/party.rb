# A ballot-qualified party within one state. The same name in two states is two parties.
class Party < Organization
  belongs_to :state
  has_many :ballot_lines, dependent: :nullify

  validates :kind, absence: true
end
