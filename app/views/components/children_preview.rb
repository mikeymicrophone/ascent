# frozen_string_literal: true

class Views::Components::ChildrenPreview < Views::ApplicationView
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
          QuickStats(item: child)
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
end
