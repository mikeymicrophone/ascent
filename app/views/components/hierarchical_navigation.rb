# frozen_string_literal: true

class Views::Components::HierarchicalNavigation < Views::ApplicationView
  include Statisticable

  def initialize(current_object:, show_stats: true, expandable: true, &drill_down_block)
    @current_object = current_object
    @show_stats = show_stats
    @expandable = expandable
    @drill_down_block = drill_down_block
    @hierarchy_chain = @current_object.build_hierarchy_chain
    @custom_stats = []
    @custom_sections = []
  end

  def view_template(&block)
    if block
      yield(NavigationBuilder.new(self))
    end

    nav(class: "hierarchical-navigation") do
      breadcrumb_chain

      if @expandable && @current_object.has_navigation_children?
        if @drill_down_block
          drill_down_section(&@drill_down_block)
        else
          drill_down_section do
            render Views::Components::ChildrenPreview.new(current_object: @current_object)
            render Views::Components::GeographicSummary.new(current_object: @current_object)
          end
        end
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

  def breadcrumb_chain
    div(class: "breadcrumb-chain") do
      @hierarchy_chain.each_with_index do |item, index|
        breadcrumb_item item, index
        span(class: "breadcrumb-separator") { ">" } unless index == @hierarchy_chain.length - 1
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

  def drill_down_section(&block)
    Views::Components::ExpandableSection(
      title: "#{@current_object.hierarchy_level_name} Overview",
      count: @current_object.nav_children_count
    ) do
      div(class: "drill-down-content", &block)
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
