class Approach < ApplicationRecord
  include Titled
  belongs_to :issue
  has_many :stances


  scope :by_issue, ->(issue_id) { where(issue_id: issue_id) if issue_id.present? }
end
