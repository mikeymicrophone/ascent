# frozen_string_literal: true

class Views::Components::HierarchicalNavigation < Views::ApplicationView
  def initialize(current_object:, show_stats: true, expandable: true)
    @current_object = current_object
    @show_stats = show_stats
    @expandable = expandable
    @hierarchy_chain = build_hierarchy_chain
  end

  def view_template(&)
    nav(class: "hierarchical-navigation") do
      render_breadcrumb_chain
      
      if @expandable && has_children?
        render_drill_down_section
      end
    end
  end

  private

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

  def render_breadcrumb_chain
    div(class: "breadcrumb-chain") do
      @hierarchy_chain.each_with_index do |item, index|
        render_breadcrumb_item(item, index)
        
        # Add separator unless it's the last item
        unless index == @hierarchy_chain.length - 1
          span(class: "breadcrumb-separator") { ">" }
        end
      end
    end
  end

  def render_breadcrumb_item(item, index)
    is_current = item == @current_object
    is_clickable = !is_current
    
    span(class: "breadcrumb-item #{'current' if is_current}") do
      if is_clickable
        link_to item.name, item, class: "breadcrumb-link"
      else
        span(class: "breadcrumb-current") { item.name }
      end
      
      if @show_stats
        render_quick_stats(item)
      end
    end
  end

  def render_quick_stats(item)
    stats = calculate_stats(item)
    
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
      end
    end
  end

  def render_drill_down_section
    Views::Components::ExpandableSection(
      title: "#{geographic_level_name(@current_object)} Overview",
      count: children_count
    ) do
      div(class: "drill-down-content") do
        render_children_preview
        render_geographic_summary
      end
    end
  end

  def render_children_preview
    children = get_children(@current_object)
    return unless children.any?
    
    div(class: "children-preview") do
      h5 { "#{child_type_name(@current_object).pluralize}" }
      
      children.take(5).each do |child|
        div(class: "child-item") do
          link_to child.name, child, class: "link child-name"
          render_quick_stats(child)
        end
      end
      
      if children.count > 5
        div(class: "children-view-all") do
          link_to "View all #{children.count} #{child_type_name(@current_object).pluralize.downcase}", 
                  [@current_object, child_route_name(@current_object)], 
                  class: "link view-all"
        end
      end
    end
  end

  def render_geographic_summary
    div(class: "geographic-summary") do
      h5 { "Geographic Summary" }
      
      summary_stats = calculate_comprehensive_stats(@current_object)
      
      div(class: "summary-grid") do
        summary_stats.each do |stat_key, stat_value|
          next if stat_value.zero?
          
          div(class: "summary-stat") do
            span(class: "summary-value") { stat_value }
            span(class: "summary-label") { humanize_stat_label(stat_key) }
          end
        end
      end
    end
  end

  def calculate_stats(item)
    case item
    when Country
      {
        voters: item.voters.count,
        active_elections: item.states.joins(cities: { offices: :elections }).merge(Election.active).count,
        total_offices: item.offices.count + item.states.joins(:offices).count + item.states.joins(cities: :offices).count
      }
    when State
      {
        voters: item.voters.count,
        active_elections: item.cities.joins(offices: :elections).merge(Election.active).count,
        total_offices: item.offices.count + item.cities.joins(:offices).count
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
    base_stats = calculate_stats(item)
    
    case item
    when Country
      base_stats.merge({
        total_states: item.states.count,
        total_cities: item.states.joins(:cities).count
      })
    when State
      base_stats.merge({
        total_cities: item.cities.count
      })
    when City
      base_stats
    else
      base_stats
    end
  end

  def has_children?
    case @current_object
    when Country
      @current_object.states.any?
    when State
      @current_object.cities.any?
    when City
      false
    else
      false
    end
  end

  def children_count
    case @current_object
    when Country
      @current_object.states.count
    when State
      @current_object.cities.count
    else
      0
    end
  end

  def get_children(item)
    case item
    when Country
      item.states.order(:name)
    when State
      item.cities.order(:name)
    else
      []
    end
  end

  def geographic_level_name(item)
    case item
    when Country
      "Country"
    when State
      "State"
    when City
      "City"
    else
      "Location"
    end
  end

  def child_type_name(item)
    case item
    when Country
      "State"
    when State
      "City"
    else
      "Location"
    end
  end

  def child_route_name(item)
    case item
    when Country
      :states
    when State
      :cities
    else
      :locations
    end
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
end