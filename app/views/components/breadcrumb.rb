# frozen_string_literal: true

# Where a page sits: links back up the trail, then the current page.
#   Breadcrumb(trail: [ [ "My ballot", ballot_path ], [ "Connecticut" ] ], current: "Governor")
# A trail entry without a path is plain text.
class Views::Components::Breadcrumb < Views::ApplicationView
  prop :trail, Array
  prop :current, _Nilable(String), default: nil
  prop :label, String, default: "Breadcrumb"

  def view_template
    nav(class: "breadcrumb", aria: { label: @label }) do
      @trail.each_with_index do |(label, path), index|
        path ? link_to(label, path, class: "breadcrumb-link") : span { label }
        span(class: "breadcrumb-separator", aria: { hidden: true }) { "/" } if index < @trail.size - 1 || @current
      end
      span(aria: { current: "page" }) { @current } if @current
    end
  end
end
