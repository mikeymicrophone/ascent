class Residence < ApplicationRecord
  belongs_to :voter
  belongs_to :jurisdiction, polymorphic: true
  
  validates :status, presence: true, inclusion: { in: %w[active inactive moved suspended] }
  validates :registered_at, presence: true
  validate :only_one_active_residence_per_voter
  
  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :recent, -> { order(registered_at: :desc) }
  
  before_create :deactivate_other_residences
  
  def name
    "#{voter.name} - #{jurisdiction.name} (#{status})"
  end
  
  def activate!
    transaction do
      # Deactivate other residences for this voter
      voter.residences.where.not(id: id).update_all(status: 'inactive')
      update!(status: 'active')
    end
  end
  
  private
  
  def only_one_active_residence_per_voter
    if status == 'active'
      existing_active = voter.residences.where(status: 'active')
      existing_active = existing_active.where.not(id: id) if persisted?
      
      if existing_active.exists?
        errors.add(:status, 'can only have one active residence per voter')
      end
    end
  end
  
  def deactivate_other_residences
    if status == 'active'
      voter.residences.where(status: 'active').update_all(status: 'inactive')
    end
  end
end