class City < ApplicationRecord
  belongs_to :state
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :registrations, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :registrations
end
