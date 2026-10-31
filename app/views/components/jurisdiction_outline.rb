# frozen_string_literal: true

# An SVG outline of a place's recorded boundary, or a clear empty state when geometry is missing.
#   JurisdictionOutline(place: county)
#   JurisdictionOutline(place: race, detail: :compact)
class Views::Components::JurisdictionOutline < Views::ApplicationView
  prop :place, _Any
  prop :detail, Symbol, default: :panel
  prop :heading, _Nilable(String)
  prop :on, _Nilable(Date)


  def view_template
    @outline = BoundaryOutline.for(@place, on: @on || Date.current, detail: @detail)
    classes = [
      "jurisdiction-outline",
      "jurisdiction-outline-#{@detail}",
      ("is-missing" unless @outline.available?)
    ].compact.join(" ")

    if @detail == :compact
      render_compact(classes)
    else
      render_panel(classes)
    end
  end

  private

  def render_panel(classes)
    section(class: classes, aria: { label: @heading || "Boundary outline" }) do
      h2(class: "jurisdiction-outline-heading") { @heading || "Boundary" }
      if @outline.available?
        div(class: "jurisdiction-outline-frame") { raw safe(@outline.svg) }
        p(class: "jurisdiction-outline-vintage") { vintage_copy }
        p(class: "jurisdiction-outline-note") do
          "Display outline is simplified from the recorded shape. Holes and separate parts are kept."
        end
        p(class: "jurisdiction-outline-exports") do
          a(href: export_path("svg"), class: "text-link") { "Download SVG" }
          plain " · "
          a(href: export_path("png"), class: "text-link") { "Download PNG" }
        end
      else
        p(class: "jurisdiction-outline-empty") do
          "No boundary is recorded for this place yet. The map explorer and place links still work without it."
        end
      end
    end
  end

  def render_compact(classes)
    div(class: classes, aria: { label: @outline.name ? "#{@outline.name} outline" : "Boundary outline" }) do
      if @outline.available?
        div(class: "jurisdiction-outline-frame") do
          raw safe(@outline.svg(css_class: "jurisdiction-outline-shape is-compact"))
        end
        span(class: "jurisdiction-outline-vintage") { "Boundary #{@outline.vintage_year}" }
      else
        span(class: "jurisdiction-outline-empty") { "No outline recorded" }
      end
    end
  end


  def vintage_copy
    year = @outline.vintage_year
    "Boundary vintage #{year}. Displaying #{year} shapes does not verify them for a later election."
  end

  def export_path(format)
    place = @outline.place
    boundary_outline_path(place_type: place.model_name.name, place_id: place.id, format: format, detail: @detail)
  end
end
