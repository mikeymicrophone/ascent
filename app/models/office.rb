class Office < ApplicationRecord
  belongs_to :position
  belongs_to :jurisdiction, polymorphic: true
  has_many :elections, dependent: :destroy
  
  validates :is_active, inclusion: { in: [true, false] }
  
  scope :active, -> { where(is_active: true) }
  scope :with_elections_and_candidates, -> { includes(:position, elections: :candidates) }
  scope :with_election_details, -> { includes(elections: [:candidacies, :office]) }

  def name
    position.title + " - " + jurisdiction.name
  end

  def recent_election
    elections.completed.recent.first
  end
  
  def current_office_holder
    recent_election&.approval_winner
  end
end
