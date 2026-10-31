class OfficialCode < ApplicationRecord
  include Titled
  belongs_to :policy


  scope :by_policy, ->(policy_id) { where(policy_id: policy_id) if policy_id.present? }
end
