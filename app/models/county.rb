class County < ApplicationRecord
  include JurisdictionOwner

  belongs_to :state
  has_many :municipalities, dependent: :nullify

  validates :name, presence: true
end
