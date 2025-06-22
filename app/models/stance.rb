class Stance < ApplicationRecord
  belongs_to :candidacy
  belongs_to :approach
  has_one :issue, through: :approach

  def name
    approach.name + " - " + candidacy.election.name
  end
end
