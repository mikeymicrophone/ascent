class Approach < ApplicationRecord
  belongs_to :issue
  has_many :stances

  alias_attribute :name, :title
end
