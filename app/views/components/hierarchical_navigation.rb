# frozen_string_literal: true

class Views::Components::HierarchicalNavigation < Views::ApplicationView
  def initialize(current_object:, show_stats: true, expandable: true)
    @current_object = current_object
    @show_stats = show_stats
    @expandable = expandable
    @hierarchy_chain = build_hierarchy_chain
    @custom_stats = []
    @custom_sections = []
  end

  def view_template(&block)
    if block
      yield(NavigationBuilder.new(self))
    end
    
    nav(class: "hierarchical-navigation") do
      breadcrumb_chain
      
      if @expandable && has_children?
        drill_down_section
      end
      
      @custom_sections.each { it[:content].call }
    end
  end

  def add_stat(key, value, label)
    @custom_stats << { key: key, value: value, label: label }
  end

  def add_custom_section(&block)
    @custom_sections << { content: block }
  end

  def build_hierarchy_chain
    chain = []
    current = @current_object
    
    # Build chain from current object up to country
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
               else
                 nil
               end
    end
    
    chain
  end

  def breadcrumb_chain
    div(class: "breadcrumb-chain") do
      @hierarchy_chain.each_with_index do |item, index|
        breadcrumb_item(item, index)
        
        # Add separator unless it's the last item
        unless index == @hierarchy_chain.length - 1
          span(class: "breadcrumb-separator") { ">" }
        end
      end
    end
  end

  def breadcrumb_item(item, index)
    span(class: "breadcrumb-item #{'current' if item == @current_object}") do
      if item != @current_object
        link_to item.name, item, class: "breadcrumb-link"
      else
        span(class: "breadcrumb-current") { item.name }
      end
      
      if @show_stats
        quick_stats(item)
      end
    end
  end

  def quick_stats(item)
    stats = electorate_stats_for(item)
    
    div(class: "quick-stats") do
      div(class: "stats-row") do
        if stats[:voters] > 0
          span(class: "stat-item voter-count") do
            span(class: "stat-value") { stats[:voters] }
            span(class: "stat-label") { "voters" }
          end
        end
        
        if stats[:active_elections] > 0
          span(class: "stat-item election-count") do
            span(class: "stat-value") { stats[:active_elections] }
            span(class: "stat-label") { "active elections" }
          end
        end
        
        if stats[:total_offices] > 0
          span(class: "stat-item office-count") do
            span(class: "stat-value") { stats[:total_offices] }
            span(class: "stat-label") { "offices" }
          end
        end
        
        @custom_stats.each do |custom_stat|
          span(class: "stat-item custom-stat") do
            span(class: "stat-value") { custom_stat[:value] }
            span(class: "stat-label") { custom_stat[:label] }
          end
        end
      end
    end
  end

  def drill_down_section
    Views::Components::ExpandableSection(
      title: "#{geographic_level_name(@current_object)} Overview",
      count: children_count
    ) do
      div(class: "drill-down-content") do
        children_preview
        geographic_summary
      end
    end
  end

  def children_preview
    children = get_children(@current_object)
    return unless children.any?
    
    div(class: "children-preview") do
      h5 { "#{child_type_name(@current_object).pluralize}" }
      
      children.take(5).each do |child|
        div(class: "child-item") do
          link_to child.name, child, class: "link child-name"
          quick_stats(child)
        end
      end
      
      if children.count > 5
        div(class: "children-view-all") do
          link_to "View all #{pluralize(children.count, child_type_name(@current_object).downcase)}", 
                  get_children_path(@current_object), 
                  class: "link view-all"
        end
      end
    end
  end

  def geographic_summary
    div(class: "geographic-summary") do
      h5 { "Geographic Summary" }
      
      div(class: "summary-grid") do
        calculate_comprehensive_stats(@current_object).each do |stat_key, stat_value|
          next if stat_value.zero?
          
          div(class: "summary-stat") do
            span(class: "summary-value") { stat_value }
            span(class: "summary-label") { humanize_stat_label(stat_key) }
          end
        end
      end
    end
  end

  def electorate_stats_for(item)
    case item
    when Country
      {
        voters: item.voters.count,
        active_elections: item.active_elections_count,
        total_offices: item.total_offices_count
      }
    when State
      {
        voters: item.voters.count,
        active_elections: item.active_elections_count,
        total_offices: item.total_offices_count
      }
    when City
      {
        voters: item.voters.count,
        active_elections: item.active_elections.count,
        total_offices: item.offices.count
      }
    else
      { voters: 0, active_elections: 0, total_offices: 0 }
    end
  end

  def calculate_comprehensive_stats(item)
    electorate_stats = electorate_stats_for(item)
    
    case item
    when Country
      electorate_stats.merge({
        total_states: item.states.count,
        total_cities: item.states.joins(:cities).count
      })
    when State
      electorate_stats.merge({
        total_cities: item.cities.count
      })
    when City
      electorate_stats
    else
      electorate_stats
    end
  end

  def has_children?
    @current_object.has_navigation_children?
  end

  def children_count
    @current_object.children_count
  end

  def get_children(item)
    item.get_children
  end

  def geographic_level_name(item)
    item.hierarchy_level_name
  end

  def child_type_name(item)
    item.child_type_name
  end

  def child_route_name(item)
    item.child_route_name
  end

  def get_children_path(item)
    item.get_children_path(self)
  end

  def humanize_stat_label(key)
    case key
    when :voters
      "Voters"
    when :active_elections
      "Active Elections"
    when :total_offices
      "Offices"
    when :total_states
      "States"
    when :total_cities
      "Cities"
    else
      key.to_s.humanize
    end
  end

  class NavigationBuilder
    def initialize(navigation)
      @navigation = navigation
    end

    def stat(key, value, label)
      @navigation.add_stat(key, value, label)
    end

    def custom_section(&block)
      @navigation.add_custom_section(&block)
    end
  end
end