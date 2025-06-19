class Office < ApplicationRecord
  belongs_to :position
  belongs_to :jurisdiction, polymorphic: true
  
  validates :is_active, inclusion: { in: [true, false] }
end
