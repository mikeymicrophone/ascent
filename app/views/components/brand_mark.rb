# frozen_string_literal: true

# Ascent's mark: a peak rising through the orange baseline, its summit lime because it is approved,
# beside a smaller peak that stays below. Colored by the brand palette in CSS.
class Views::Components::BrandMark < Views::ApplicationView
  def view_template
    svg(class: "brand-mark", viewbox: "0 0 40 40", aria: { hidden: true }) do |s|
      s.path(class: "brand-mark-far", d: "M1 34 L11 19 L21 34 Z")
      s.path(class: "brand-mark-near", d: "M7 34 L22 6 L37 34 Z")
      s.path(class: "brand-mark-summit", d: "M16.64 16 L22 6 L27.36 16 Z")
      s.path(class: "brand-mark-rope", d: "M2 16 H38")
    end
  end
end
