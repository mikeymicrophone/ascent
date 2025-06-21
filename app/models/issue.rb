class Issue < ApplicationRecord
  belongs_to :topic
  has_many :approaches

  alias_attribute :name, :title
end
