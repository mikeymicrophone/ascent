# frozen_string_literal: true

# The page around a long, filterable list: the header, tabs and filters, then the rows and the pager in a
# Turbo frame, so paging swaps only the list and keeps the filters.
#   IndexPage(title: "Every race", records: @races, pagy: @pagy, noun: "race", frame: "races-list",
#     tabs: method(:status_tabs), filters: method(:filter_form), clear_path: races_path) { |race| ListRow(...) }
class Views::Components::IndexPage < Views::ApplicationView
  prop :title, String
  prop :records, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :noun, String
  prop :frame, String
  prop :eyebrow, _Nilable(String)
  prop :lede, _Nilable(String)
  prop :trail, Array, default: -> { [] }
  prop :clear_path, _Nilable(String)
  prop :empty_title, _Nilable(String)
  prop :empty_text, _Nilable(String)
  prop :actions, _Callable?
  prop :tabs, _Callable?
  prop :filters, _Callable?
  prop :aside, _Callable?

  def view_template(&row)
    div(class: "index-page #{@frame}-page") do
      PageHeader(title: @title, trail: @trail, eyebrow: @eyebrow, lede: @lede, icon_for: @records.model, modifier: "index-header", &(proc { @actions.call } if @actions))
      @aside&.call
      @tabs&.call
      div(class: "index-filters") { @filters.call } if @filters
      turbo_frame_tag(@frame, target: "_top", class: "index-results", autoscroll: true,
        data: { autoscroll_block: "start", controller: "paged-list", action: "turbo:frame-load->paged-list#settle" }) do
        @records.any? ? results(&row) : empty_state
      end
    end
  end

  private

  def results(&row)
    p(class: "index-count", role: "status") { "#{delimited(@pagy&.count || @records.size)} #{@noun.pluralize(@pagy&.count || @records.size)}" }
    ul(class: "list-rows", data: { controller: "reveal" }) { @records.each(&row) }
    Pagination(pagy: @pagy, noun: @noun.pluralize, frame: @frame)
  end

  def empty_state
    section(class: "index-empty") do
      span(class: "index-empty-icon") { icon(:search_x) }
      h2(class: "card-title") { @empty_title || "No #{@noun.pluralize} match" }
      p(class: "card-text") { @empty_text || "Try a different search or fewer filters." }
      PillLink(label: "Clear filters", path: @clear_path, variant: "outline") if @clear_path
    end
  end
end
