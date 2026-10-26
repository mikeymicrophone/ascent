class District < ApplicationRecord
  include JurisdictionOwner

  validates :name, :kind, presence: true

  def congressional?
    kind.include?("congressional")
  end
end
