class Issue < ApplicationRecord
  belongs_to :topic
  has_many :approaches
  has_many :stances, through: :approaches

  alias_attribute :name, :title
end
