# frozen_string_literal: true

class Views::Components::HierarchicalNavigation < Views::ApplicationView
  prop :current_object, Hierarchicable
  prop :show_stats, _Boolean, default: true
  prop :expandable, _Boolean, default: true

  def after_initialize
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
        drill_down_section do
          render Views::Components::ChildrenPreview.new(current_object: @current_object)
          render Views::Components::GeographicSummary.new(current_object: @current_object)
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
        span(class: "breadcrumb-separator") { icon(:chevron_right) } unless index == @hierarchy_chain.length - 1
      end
    end
  end

  def breadcrumb_item(item, index)
    span(class: [ "breadcrumb-item", ("current" if item == @current_object) ]) do
      if item != @current_object
        link_to item.name, item, class: "breadcrumb-link"
      else
        span(class: "breadcrumb-current") { item.name }
      end

      QuickStats(item: item, custom_stats: @custom_stats) if @show_stats
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
