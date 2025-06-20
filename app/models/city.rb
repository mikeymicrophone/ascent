class City < ApplicationRecord
  belongs_to :state
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :residences, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :residences
end
