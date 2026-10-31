class VoterStatement < ApplicationRecord
  include OrderedVoterContent

  normalizes :body, with: -> { it.strip }
  validates :body, presence: true
end
