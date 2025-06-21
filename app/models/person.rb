class Person < ApplicationRecord
  has_many :candidacies, dependent: :destroy
  has_many :elections, through: :candidacies
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  
  scope :with_candidacy_details, -> { includes(candidacies: [election: [office: :position]]) }
  scope :with_recent_candidacies, -> { 
    includes(candidacies: [election: [office: :position]])
      .joins(:candidacies, candidacies: :election)
      .order('elections.election_date DESC') 
  }
  
  def full_name
    [first_name, middle_name, last_name].compact.join(' ')
  end
  
  def name
    full_name
  end
end
