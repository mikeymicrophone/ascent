class State < ApplicationRecord
  belongs_to :country
  has_many :cities, dependent: :destroy
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :residences, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :residences
end
