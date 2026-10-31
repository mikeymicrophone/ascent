# frozen_string_literal: true

# Selected place outline with same-layer neighbors highlighted, plus separate overlapping-type links.
class Views::Components::JurisdictionNeighborhood < Views::ApplicationView
  prop :place, _Any
  prop :on, _Nilable(Date)

  def view_template
    @neighborhood = BoundaryNeighborhood.for(@place, on: @on || Date.current)
    return render_missing unless @neighborhood.available?

    section(class: "jurisdiction-neighborhood", aria: { label: "Neighboring jurisdictions" }) do
      h2(class: "jurisdiction-outline-heading") { "Neighbors" }
      div(class: "jurisdiction-outline-frame jurisdiction-neighborhood-frame") { raw safe(@neighborhood.svg) }
      p(class: "jurisdiction-outline-vintage") do
        "Boundary vintage #{@neighborhood.vintage_year}. Same-layer neighbors touch this outline, including at a point."
      end
      render_same_layer
      render_overlaps
      p(class: "jurisdiction-outline-note") do
        "Islands with no touching peer list no same-layer neighbors. Overlapping jurisdictions of other types are listed separately."
      end
    end
  end

  private

  def render_missing
    section(class: "jurisdiction-neighborhood is-missing", aria: { label: "Neighboring jurisdictions" }) do
      h2(class: "jurisdiction-outline-heading") { "Neighbors" }
      p(class: "jurisdiction-outline-empty") do
        "Neighbor context needs a recorded boundary for this place."
      end
    end
  end

  def render_same_layer
    neighbors = @neighborhood.same_layer_neighbors
    h3(class: "jurisdiction-neighborhood-subheading") { "Same-layer neighbors" }
    if neighbors.empty?
      p(class: "jurisdiction-outline-empty") { "No touching #{@place.model_name.human.downcase} neighbors are recorded." }
    else
      ul(class: "nearby-list jurisdiction-neighbor-links") do
        neighbors.each do |neighbor|
          li { link_to neighbor.name, neighbor, class: "text-link" }
        end
      end
    end
  end

  def render_overlaps
    overlaps = @neighborhood.overlapping_other_types
    h3(class: "jurisdiction-neighborhood-subheading") { "Overlapping other types" }
    if overlaps.empty?
      p(class: "jurisdiction-outline-empty") { "No overlapping jurisdictions of another type are recorded." }
    else
      ul(class: "nearby-list jurisdiction-neighbor-links") do
        overlaps.each do |record|
          li do
            link_to "#{record.name} (#{record.model_name.human.downcase})", record, class: "text-link"
          end
        end
      end
    end
  end
end
