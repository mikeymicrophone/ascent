# frozen_string_literal: true

module Hierarchicable
  extend ActiveSupport::Concern

  HIERARCHY_CONFIG = {
    # Geographic hierarchy
    'Country' => {
      children_relation: :states,
      display_name: 'Country',
      child_type_name: 'State',
      child_route_name: :states,
      children_scope: ->(item) { item.states.with_election_data.order(:name) },
      children_path: ->(item, context) { [item, :states] }
    },
    'State' => {
      children_relation: :cities,
      display_name: 'State',
      child_type_name: 'City',
      child_route_name: :cities,
      children_scope: ->(item) { item.cities.with_office_data.order(:name) },
      children_path: ->(item, context) { context.respond_to?(:cities_path) ? context.cities_path : '/cities' }
    },
    'City' => {
      children_relation: nil,
      display_name: 'City',
      child_type_name: nil,
      child_route_name: nil,
      children_scope: ->(_item) { [] },
      children_path: ->(_item, context) { context.respond_to?(:root_path) ? context.root_path : '/' }
    },
    
    # Policy/Topic hierarchy
    'Topic' => {
      children_relation: :issues,
      display_name: 'Topic',
      child_type_name: 'Issue',
      child_route_name: :issues,
      children_scope: ->(item) { item.issues.order(:name) },
      children_path: ->(item, context) { [item, :issues] }
    },
    'Issue' => {
      children_relation: :approaches,
      display_name: 'Issue',
      child_type_name: 'Approach',
      child_route_name: :approaches,
      children_scope: ->(item) { item.approaches.order(:name) },
      children_path: ->(item, context) { [item, :approaches] }
    },
    'Approach' => {
      children_relation: :stances,
      display_name: 'Approach',
      child_type_name: 'Stance',
      child_route_name: :stances,
      children_scope: ->(item) { item.stances.order(:name) },
      children_path: ->(item, context) { [item, :stances] }
    },
    'Stance' => {
      children_relation: nil,
      display_name: 'Stance',
      child_type_name: nil,
      child_route_name: nil,
      children_scope: ->(_item) { [] },
      children_path: ->(_item, context) { context.respond_to?(:root_path) ? context.root_path : '/' }
    },
    
    # Governance structure hierarchy
    'GovernanceType' => {
      children_relation: :governing_bodies,
      display_name: 'Governance Type',
      child_type_name: 'Governing Body',
      child_route_name: :governing_bodies,
      children_scope: ->(item) { item.governing_bodies.order(:name) },
      children_path: ->(item, context) { [item, :governing_bodies] }
    },
    'GoverningBody' => {
      children_relation: :policies,
      display_name: 'Governing Body',
      child_type_name: 'Policy',
      child_route_name: :policies,
      children_scope: ->(item) { item.policies.order(:name) },
      children_path: ->(item, context) { [item, :policies] }
    },
    'Policy' => {
      children_relation: :official_codes,
      display_name: 'Policy',
      child_type_name: 'Official Code',
      child_route_name: :official_codes,
      children_scope: ->(item) { item.official_codes.order(:name) },
      children_path: ->(item, context) { [item, :official_codes] }
    },
    'OfficialCode' => {
      children_relation: nil,
      display_name: 'Official Code',
      child_type_name: nil,
      child_route_name: nil,
      children_scope: ->(_item) { [] },
      children_path: ->(_item, context) { context.respond_to?(:root_path) ? context.root_path : '/' }
    }
  }.freeze

  def has_navigation_children?(context = nil)
    raise NotImplementedError, "Array contexts not yet supported" if context.is_a?(Array)
    
    config = hierarchy_config
    return false unless config&.dig(:children_relation)
    
    send(config[:children_relation]).any?
  end

  def nav_children_count
    config = hierarchy_config
    return 0 unless config&.dig(:children_relation)
    
    send(config[:children_relation]).count
  end

  def nav_children
    config = hierarchy_config
    return [] unless config&.dig(:children_scope)
    
    config[:children_scope].call(self)
  end

  def hierarchy_level_name
    config = hierarchy_config
    config&.dig(:display_name) || 'Unknown'
  end

  def nav_child_type_name
    config = hierarchy_config
    config&.dig(:child_type_name) || 'Item'
  end

  def nav_child_route_name
    config = hierarchy_config
    config&.dig(:child_route_name)
  end

  def nav_children_path(context = nil)
    config = hierarchy_config
    return (context.respond_to?(:root_path) ? context.root_path : '/') unless config&.dig(:children_path)
    
    config[:children_path].call(self, context)
  end

  def build_hierarchy_chain
    chain = []
    current = self
    
    # Build chain from current object up to root
    while current
      chain.unshift(current)
      
      # Use string-based class matching to avoid Rails autoloading issues
      current = case current.class.name
               when 'City'
                 current.state
               when 'State'
                 current.country
               when 'Country'
                 nil
               when 'Issue'
                 current.topic
               when 'Approach'
                 current.issue
               when 'Stance'
                 current.approach
               when 'GoverningBody'
                 current.governance_type
               when 'Policy'
                 current.governing_body
               when 'OfficialCode'
                 current.policy
               else
                 nil
               end
    end
    
    chain
  end

  private

  def hierarchy_config
    HIERARCHY_CONFIG[self.class.name]
  end
end