class Stance < ApplicationRecord
  belongs_to :candidacy
  belongs_to :issue
  belongs_to :approach
end
