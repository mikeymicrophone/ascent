class Approach < ApplicationRecord
  include Titled
  belongs_to :issue
  has_many :stances


  scope :by_issue, ->(issue_id) { where(issue_id: issue_id) if issue_id.present? }
  scope :by_topic, ->(topic_id) { joins(:issue).where(issues: { topic_id: topic_id }) if topic_id.present? }
end
