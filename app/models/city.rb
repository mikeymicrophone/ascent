class City < ApplicationRecord
  belongs_to :state
  has_many :offices, as: :jurisdiction, dependent: :destroy
end
