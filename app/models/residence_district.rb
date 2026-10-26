# A district a residence sits in, recorded by hand where we hold no boundary to find it from.
class ResidenceDistrict < ApplicationRecord
  belongs_to :residence
  belongs_to :jurisdiction

  validates :jurisdiction_id, uniqueness: { scope: :residence_id }
end
