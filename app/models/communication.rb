# Something a campaign published or said: a video, post, ad, speech, debate clip, interview,
# platform page, or mailer. Ascent keeps links, a short summary, and quotes, never the media itself.
class Communication < ApplicationRecord
  KINDS = %w[video post ad speech debate interview platform press_release mailer other].freeze
  AVAILABILITY = %w[available edited removed].freeze
  WEB_ADDRESS = %r{\Ahttps?://\S+\z}

  belongs_to :channel, optional: true
  has_many :communication_features, dependent: :destroy
  has_many :featured_candidacies, through: :communication_features, source: :candidacy
  has_many :stance_evidences, dependent: :restrict_with_error

  validates :kind, inclusion: { in: KINDS }
  validates :availability, inclusion: { in: AVAILABILITY }
  validates :published_on, presence: true
  validates :url, presence: true, uniqueness: true, format: { with: WEB_ADDRESS }
  validates :archived_url, format: { with: WEB_ADDRESS }, allow_blank: true
  validates :duration_seconds, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  def name
    title.presence || "#{kind.humanize} published #{published_on}"
  end
end
