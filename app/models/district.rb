class District < ApplicationRecord
  include JurisdictionOwner

  validates :name, :kind, presence: true
end
