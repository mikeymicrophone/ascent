# frozen_string_literal: true

# One record in a list: its icon, its title as the link, a line or two about it, chips, and a chevron.
# The whole row opens the record; anything the block draws in the trailing slot stays clickable on its own.
#   ListRow(record: race, title: race.office.name, meta: "Nov 3, 2026 · 4 candidates") { StatusChip(status: race.status) }
class Views::Components::ListRow < Views::ApplicationView
  prop :record, ActiveRecord::Base
  prop :title, String
  prop :path, _Nilable(String)
  prop :meta, _Nilable(String)
  prop :detail, _Nilable(String)
  prop :modifier, _Nilable(String)

  def view_template(&badges)
    li(class: [ "list-row", @modifier ].compact.join(" "), id: dom_id(@record, :list_item), data: { reveal_target: "item" }) do
      span(class: "list-row-icon") { entity_icon(@record) }
      div(class: "list-row-main") do
        link_to @title, @path || @record, class: "list-row-title", style: "view-transition-name: #{dom_id(@record, :title)}"
        span(class: "list-row-meta") { @meta } if @meta
        span(class: "list-row-detail") { @detail } if @detail
      end
      div(class: "list-row-badges", &badges) if badges
      span(class: "list-row-chevron") { icon(:chevron_right) }
    end
  end
end
