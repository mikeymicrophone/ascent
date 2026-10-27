# A candidacy that appears in a communication.
class CommunicationFeature < ApplicationRecord
  belongs_to :communication
  belongs_to :candidacy

  validates :candidacy_id, uniqueness: { scope: :communication_id }
end
