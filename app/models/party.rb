# A ballot-qualified party within one state. The same name in two states is two parties.
class Party < ApplicationRecord
  belongs_to :state
  has_many :ballot_lines, dependent: :nullify
  has_many :endorsements, as: :endorser, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :state_id }
end
