class Inquiry
  include ActiveModel::Model
  include ActiveModel::Attributes

  SUBJECT_TAGS = [
    "features",
    "question",
    "I’m involved in an election",
    "I want to invest"
  ].freeze

  attribute :email, :string
  attribute :subject, :string
  attribute :message, :string

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true
  validates :message, presence: true
end
