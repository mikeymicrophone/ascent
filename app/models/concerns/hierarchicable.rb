# frozen_string_literal: true

# A record's chain of parents within its own hierarchy, from the top down to itself, such as an approach's
# topic, issue and approach, or a policy's governance type, governing body and policy.
module Hierarchicable
  extend ActiveSupport::Concern

  PARENTS = {
    "Municipality" => ->(record) { record.county || record.state },
    "County" => :state,
    "State" => :country,
    "Issue" => :topic,
    "Approach" => :issue,
    "Stance" => :approach,
    "GoverningBody" => :governance_type,
    "Policy" => :governing_body,
    "OfficialCode" => :policy
  }.freeze

  def build_hierarchy_chain
    chain = []
    current = self
    while current
      chain.unshift(current)
      parent = PARENTS[current.class.name]
      current = parent.is_a?(Proc) ? parent.call(current) : (parent && current.public_send(parent))
    end
    chain
  end
end
