class Person < ApplicationRecord
  include Engageable

  has_many :candidacies, dependent: :destroy
  has_many :races, -> { distinct }, through: :candidacies
  has_many :elections, -> { distinct }, through: :races

  # Ballots name candidates without contact details, and some print only a surname.
  validates :last_name, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  # Generated usernames stay provisional until a verified handle replaces them.
  validates :username, uniqueness: true, format: { with: /\A[a-z0-9_]+\z/ }, allow_blank: true
  validates :username_status, inclusion: { in: %w[provisional verified] }, if: :username?

  # Invented candidates in mock elections are kept apart from real people.
  scope :real, -> { where(fictional: false) }
  scope :fictional, -> { where(fictional: true) }
  scope :with_candidacy_details, -> { includes(candidacies: { race: [ :election, { office: :position } ] }) }
  scope :with_recent_candidacies, -> {
    includes(candidacies: { race: [ :election, { office: :position } ] })
      .joins(candidacies: { race: :election })
      .order("elections.election_date DESC")
  }

  def full_name
    [ first_name, middle_name, last_name ].compact.join(" ")
  end

  def name
    full_name
  end
end
