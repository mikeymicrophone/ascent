class Office < ApplicationRecord
  belongs_to :position
  belongs_to :jurisdiction, polymorphic: true
  has_many :elections, dependent: :destroy
  
  validates :is_active, inclusion: { in: [true, false] }

  def name
    position.title + " - " + jurisdiction.name
  end
end
