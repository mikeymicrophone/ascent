# frozen_string_literal: true

# Where a page sits: links back up the trail, then the current page.
#   Breadcrumb(trail: [ [ "My ballot", ballot_path ], [ "Connecticut" ] ], current: "Governor")
# A trail entry without a path is plain text.
class Views::Components::Breadcrumb < Views::ApplicationView
  prop :trail, Array
  prop :current, String

  def view_template
    nav(class: "breadcrumb", aria: { label: "Breadcrumb" }) do
      @trail.each do |label, path|
        path ? link_to(label, path, class: "breadcrumb-link") : span { label }
        span(class: "breadcrumb-separator", aria: { hidden: true }) { "/" }
      end
      span(aria: { current: "page" }) { @current }
    end
  end
end
