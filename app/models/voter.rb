class Voter < ApplicationRecord
  # Include default devise modules. Others available are:
  # :registerable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  
  has_many :residences, dependent: :destroy
  has_many :jurisdictions, through: :residences
  has_many :ratings, dependent: :destroy
  has_many :voter_election_baselines, dependent: :destroy
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  # validates :is_verified, inclusion: { in: [true, false] }
  
  def full_name
    [first_name, last_name].compact.join(' ')
  end
  
  def name
    full_name
  end
  
  def current_residence
    residences.where(status: 'active').first
  end
  
  def residence_history
    residences.order(registered_at: :desc)
  end
  
  def eligible_for_election?(election)
    return true
    return false unless current_residence
    
    # Check if voter's current jurisdiction is eligible for this election
    office_jurisdiction = election.office.jurisdiction
    voter_jurisdiction = current_residence.jurisdiction
    
    # Direct match
    return true if voter_jurisdiction == office_jurisdiction
    
    # Hierarchical match (e.g., voter in city can vote for state/country elections)
    case office_jurisdiction
    when Country
      # Country elections: voter must be in that country (via state/city)
      voter_jurisdiction.is_a?(State) && voter_jurisdiction.country == office_jurisdiction ||
      voter_jurisdiction.is_a?(City) && voter_jurisdiction.state.country == office_jurisdiction
    when State
      # State elections: voter must be in that state (directly or via city)
      voter_jurisdiction == office_jurisdiction ||
      (voter_jurisdiction.is_a?(City) && voter_jurisdiction.state == office_jurisdiction)
    else
      false
    end
  end
end
