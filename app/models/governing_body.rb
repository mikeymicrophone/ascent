class GoverningBody < ApplicationRecord
  belongs_to :governance_type
  belongs_to :jurisdiction, polymorphic: true
  
  validates :name, presence: true
  validates :jurisdiction_type, presence: true
  validates :jurisdiction_id, presence: true
  validates :meeting_schedule, presence: true
  
  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }
  scope :by_governance_type, ->(type_id) { where(governance_type_id: type_id) if type_id.present? }
  scope :by_jurisdiction_type, ->(type) { where(jurisdiction_type: type) if type.present? }
  scope :established_before, ->(date) { where('established_date <= ?', date) if date.present? }
  scope :established_after, ->(date) { where('established_date >= ?', date) if date.present? }
  
  def jurisdiction_name
    jurisdiction&.name || "Unknown Jurisdiction"
  end
  
  def governance_type_name
    governance_type&.name || "Unknown Type"
  end
  
  def formatted_established_date
    established_date&.strftime("%B %Y") || "Unknown"
  end
end
