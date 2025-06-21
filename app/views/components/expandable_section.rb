# frozen_string_literal: true

class Views::Components::ExpandableSection < Views::ApplicationView
  def initialize(title:, count: nil, expanded: false)
    @title = title
    @count = count
    @expanded = expanded
  end

  def view_template(&block)
    div(class: "expandable-section", data: { controller: "expandable-section" }) do
      button(
        class: "expandable-header",
        data: { 
          action: "click->expandable-section#toggle",
          expandable_section_target: "toggle"
        }
      ) do
        div(class: "expandable-title") do
          span { @title }
          if @count
            whitespace
            span(class: "expandable-count") { "(#{@count})" }
          end
        end
        div(class: "expandable-icon") do
          # Using simple text arrows, can be replaced with icons later
          span(data: { expandable_section_target: "icon" }) { @expanded ? "▼" : "▶" }
        end
      end
      
      div(
        class: "expandable-content",
        data: { expandable_section_target: "content" },
        style: (@expanded ? "" : "display: none;")
      ) do
        yield if block
      end
    end
  end
end