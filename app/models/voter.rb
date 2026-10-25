class Voter < ApplicationRecord
  # Include default devise modules. Others available are:
  # :registerable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :confirmable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]
  
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

  def self.google_sign_in_available?
    Devise.omniauth_configs.key?(:google_oauth2)
  end

  # The voter a Google account signs in as: the one already linked to it, else the one with its
  # verified email, which it then links, else a new confirmed voter with a random password.
  # Returns an unsaved voter with errors when none can be made.
  def self.from_google(auth)
    find_by(provider: auth.provider, uid: auth.uid) || link_google(auth) || create_from_google(auth)
  end

  def self.link_google(auth)
    return unless google_email_verified?(auth)

    find_by(email: auth.info.email.downcase)&.tap do |voter|
      voter.skip_reconfirmation!
      voter.confirm unless voter.confirmed?
      voter.update!(provider: auth.provider, uid: auth.uid)
    end
  end

  def self.create_from_google(auth)
    voter = new(provider: auth.provider, uid: auth.uid, email: auth.info.email,
                first_name: auth.info.first_name, last_name: auth.info.last_name,
                password: Devise.friendly_token(32))
    unless google_email_verified?(auth)
      voter.errors.add(:email, "is not verified with Google")
      return voter
    end

    voter.skip_confirmation!
    voter.save
    voter
  end

  def self.google_email_verified?(auth)
    auth.extra&.raw_info&.email_verified == true || auth.info.email_verified == true
  end
  private_class_method :link_google, :create_from_google, :google_email_verified?

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
