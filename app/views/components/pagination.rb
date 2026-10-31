# frozen_string_literal: true

# Where a long list is up to, and the way to the pages around it: "Showing 26–50 of 4,743 races", then
# previous, a window of page numbers, and next. On a phone the numbers fold to "Page 2 of 190".
#   Pagination(pagy: @pagy, noun: "races", frame: "races-list")
# Given a frame, its links swap only that Turbo frame and still advance the address bar.
class Views::Components::Pagination < Views::ApplicationView
  WINDOW = 1

  prop :pagy, _Nilable(Pagy)
  prop :noun, _Nilable(String)
  prop :frame, _Nilable(String)

  def view_template
    return unless @pagy && @pagy.last > 1

    nav(class: "pagination", aria: { label: "Pagination" }) do
      p(class: "pagination-info") { info }
      div(class: "pagination-nav") do
        step(:previous, "Previous", :chevron_left)
        ol(class: "pagination-pages") { pages.each { page_item(it) } }
        span(class: "pagination-compact") { "Page #{delimited(@pagy.page)} of #{delimited(@pagy.last)}" }
        step(:next, "Next", :chevron_right)
      end
    end
  end

  private

  def info
    "Showing #{delimited(@pagy.from)}–#{delimited(@pagy.to)} of #{delimited(@pagy.count)}#{" #{@noun}" if @noun}"
  end

  # The first and last pages, the current page with its neighbours, and :gap wherever pages are skipped.
  def pages
    shown = [ 1, @pagy.last, *(@pagy.page - WINDOW..@pagy.page + WINDOW) ].select { it.between?(1, @pagy.last) }.uniq.sort
    shown.each_cons(2).flat_map { |page, following| following - page > 1 ? [ page, :gap ] : [ page ] } + [ shown.last ]
  end

  def page_item(page)
    li do
      if page == :gap
        span(class: "pagination-gap", aria: { hidden: true }) { "…" }
      elsif page == @pagy.page
        span(class: "pagination-page is-current", aria: { current: "page" }) { delimited(page) }
      else
        a(href: @pagy.page_url(page), class: "pagination-page", aria: { label: "Page #{page}" }, data: frame_data) { delimited(page) }
      end
    end
  end

  def step(direction, label, icon_name)
    target = @pagy.public_send(direction)
    content = proc {
      icon(icon_name)
      span(class: "pagination-step-label") { label }
    }
    if target
      a(href: @pagy.page_url(target), class: "pagination-step pagination-#{direction}", rel: (direction == :previous ? "prev" : "next"),
        aria: { label: "#{label} page" }, data: frame_data, &content)
    else
      span(class: "pagination-step pagination-#{direction} is-disabled", aria: { disabled: true }, &content)
    end
  end

  def frame_data
    { turbo_frame: @frame, turbo_action: "advance" } if @frame
  end
end
