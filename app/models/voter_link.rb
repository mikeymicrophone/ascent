class VoterLink < ApplicationRecord
  include OrderedVoterContent

  normalizes :label, :url, with: -> { it.strip }
  validates :label, :url, presence: true
  validate :http_url

  private

  def http_url
    return if url.blank?

    uri = URI.parse(url)
    errors.add(:url, "must be an HTTP or HTTPS URL") unless uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:url, "must be an HTTP or HTTPS URL")
  end
end
