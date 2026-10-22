class Approach < ApplicationRecord
  belongs_to :issue
  has_many :stances

  alias_attribute :name, :title

  scope :by_issue, ->(issue_id) { where(issue_id: issue_id) if issue_id.present? }
end
