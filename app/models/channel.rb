# One account on one platform, such as a campaign's YouTube channel or a candidate's Instagram.
class Channel < ApplicationRecord
  PLATFORMS = %w[website youtube instagram tiktok x bluesky facebook threads other].freeze
  # Stored as each owner's base class, so a party is an Organization.
  OWNER_TYPES = %w[Person Organization Candidacy].freeze

  belongs_to :owner, polymorphic: true, optional: true
  has_many :communications, dependent: :restrict_with_error

  validates :platform, inclusion: { in: PLATFORMS }
  validates :handle, presence: true, uniqueness: { scope: :platform }
  validates :owner_type, inclusion: { in: OWNER_TYPES }, allow_nil: true
  validates :official, inclusion: { in: [ true, false ] }

  scope :official, -> { where(official: true) }

  def name
    "#{handle} on #{platform}"
  end
end
