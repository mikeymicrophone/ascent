class Voter < ApplicationRecord
  # Include default devise modules. Others available are:
  # :registerable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  
  has_many :residences, dependent: :destroy
  has_many :jurisdictions, through: :residences
  has_many :ratings, dependent: :destroy
  has_many :voter_race_baselines, dependent: :destroy
  has_many :voter_race_baseline_archives, dependent: :delete_all
  has_many :engagements, dependent: :destroy
  has_many :voter_race_preferences, dependent: :delete_all
  
  validates :first_name, presence: true
  validates :last_name, presence: true
  # validates :is_verified, inclusion: { in: [true, false] }
  
  scope :with_voting_activity, -> {
    includes(:ratings, :voter_race_baselines,
             ratings: { candidacy: { race: [:election, { office: :position }] } },
             voter_race_baselines: { race: [:election, { office: :position }] })
  }
  scope :with_residence_details, -> { includes(residences: :jurisdiction) }

  def admin?
    admin
  end
  
  def full_name
    [first_name, last_name].compact.join(' ')
  end
  
  def name
    full_name
  end
  
  def race_preference(race)
    voter_race_preferences.find_by(race: race) || VoterRacePreference.new(voter: self, race: race)
  end

  # Whether this voter also rates the candidates the race's primaries eliminated; off by default.
  def includes_primary_candidates?(race)
    race_preference(race).include_primary_candidates?
  end

  def include_primary_candidates!(race, included)
    race_preference(race).update!(include_primary_candidates: included)
  end

  def current_residence
    residences.where(status: 'active').first
  end
  
  def residence_history
    residences.order(registered_at: :desc)
  end
  
end
