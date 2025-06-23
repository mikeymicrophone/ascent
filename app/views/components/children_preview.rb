# frozen_string_literal: true

class Views::Components::ChildrenPreview < Views::ApplicationView
  include Statisticable

  def initialize(current_object:)
    @current_object = current_object
  end

  def view_template
    children = @current_object.nav_children
    return unless children.any?
    
    div(class: "children-preview") do
      h5 { "#{@current_object.nav_child_type_name.pluralize}" }
      
      children.take(5).each do |child|
        div(class: "child-item") do
          link_to child.name, child, class: "link child-name"
          quick_stats(child)
        end
      end
      
      if children.count > 5
        div(class: "children-view-all") do
          link_to "View all #{pluralize(children.count, @current_object.nav_child_type_name.downcase)}",
                  @current_object.nav_children_path(self),
                  class: "link view-all"
        end
      end
    end
  end

  private

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
      end
    end
  end
end