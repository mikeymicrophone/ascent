class OfficialCode < ApplicationRecord
  belongs_to :policy

  alias_attribute :name, :title
end
