class State < ApplicationRecord
  belongs_to :country
  has_many :cities, dependent: :destroy
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :registrations, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :registrations
end
