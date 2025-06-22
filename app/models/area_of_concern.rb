class AreaOfConcern < ApplicationRecord
  validates :name, presence: true
  validates :policy_domain, presence: true
  
  scope :by_domain, ->(domain) { where(policy_domain: domain) if domain.present? }
  scope :by_scope, ->(scope) { where(regulatory_scope: scope) if scope.present? }
end
