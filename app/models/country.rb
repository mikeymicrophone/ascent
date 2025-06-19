class Country < ApplicationRecord
  has_many :states, dependent: :destroy
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :registrations, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :registrations
end
