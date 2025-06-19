class Country < ApplicationRecord
  has_many :states, dependent: :destroy
end
