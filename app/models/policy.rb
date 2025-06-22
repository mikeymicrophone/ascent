class Policy < ApplicationRecord
  belongs_to :governing_body
  belongs_to :area_of_concern
  belongs_to :approach

  enum :status, { pending: 0, enacted: 1, repealed: 2 }

  alias_attribute :name, :title
end
