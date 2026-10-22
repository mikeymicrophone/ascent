# frozen_string_literal: true

# Ascent's mark: two peaks under an approval check, colored by the brand palette in CSS.
class Views::Components::BrandMark < Views::ApplicationView
  def view_template
    svg(class: "brand-mark", viewbox: "0 0 40 40", aria: { hidden: true }) do |s|
      s.path(class: "brand-mark-far", d: "M3 34 L16 13 L24 25 L20 34 Z")
      s.path(class: "brand-mark-near", d: "M11 34 L25 15 L37 34 Z")
      s.path(class: "brand-mark-snow", d: "M25 15 L29.4 21 L27.2 20 L25 22.2 L22.8 20 L20.6 21 Z")
      s.path(class: "brand-mark-check", d: "M18.5 8.5 L22 12 L29 5")
    end
  end
end
