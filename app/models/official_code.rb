class OfficialCode < ApplicationRecord
  belongs_to :policy

  alias_attribute :name, :title

  scope :by_policy, ->(policy_id) { where(policy_id: policy_id) if policy_id.present? }
end
