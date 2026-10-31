class Topic < ApplicationRecord
  include Titled
  has_many :issues
  has_many :approaches, through: :issues
  has_many :stances, through: :issues
end
