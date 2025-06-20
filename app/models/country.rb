class Country < ApplicationRecord
  has_many :states, dependent: :destroy
  has_many :offices, as: :jurisdiction, dependent: :destroy
  has_many :residences, as: :jurisdiction, dependent: :destroy
  has_many :voters, through: :residences
end
