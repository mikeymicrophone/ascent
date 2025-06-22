class Topic < ApplicationRecord
  has_many :issues
  has_many :approaches, through: :issues
  has_many :stances, through: :issues

  alias_attribute :name, :title
end
