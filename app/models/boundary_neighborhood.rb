# frozen_string_literal: true

# Same-layer neighbors and other-type overlaps for one jurisdiction's effective boundary.
#
# Adjacency (same layer): effective MultiPolygons that ST_Touches the selected shape,
# including point-touching corners. Interiors that only overlap are not same-layer neighbors.
# Islands with no touching peer have an empty same-layer neighbor set.
#
# Other-type context: jurisdictions of a different type whose effective boundary overlaps the
# selected shape beyond a digitizing sliver (Jurisdiction.overlapping). Listed separately.
class BoundaryNeighborhood
  LIMIT = 24
  TOLERANCE = 0.002
  PADDING_RATIO = 0.08

  Member = Data.define(:place, :path_data, :selected)

  attr_reader :place, :on

  def self.for(place, on: Date.current)
    new(place, on: on)
  end

  def initialize(place, on: Date.current)
    @place = place
    @jurisdiction = place.jurisdiction
    @on = on
  end

  def available?
    selected_boundary.present?
  end

  def selected_boundary
    return @selected_boundary if defined?(@selected_boundary)

    @selected_boundary = @jurisdiction &&
      JurisdictionBoundary.effective_on(@on).where(jurisdiction: @jurisdiction).order(:valid_from).first
  end

  def vintage_year
    selected_boundary&.valid_from&.year
  end

  def same_layer_neighbors
    return [] unless available?

    @same_layer_neighbors ||= begin
      neighbor_jurisdictions = Jurisdiction
        .where(jurisdictionable_type: @jurisdiction.jurisdictionable_type)
        .where.not(id: @jurisdiction.id)
        .then { |scope| restrict_district_kind(scope) }
        .joins(:boundaries)
        .merge(JurisdictionBoundary.effective_on(@on))
        .where(
          "ST_Touches(jurisdiction_boundaries.geometry, (SELECT geometry FROM jurisdiction_boundaries WHERE id = ?))",
          selected_boundary.id
        )
        .distinct
        .includes(:jurisdictionable)
        .limit(LIMIT)

      neighbor_jurisdictions.map(&:jurisdictionable).compact.sort_by(&:name)
    end
  end

  def overlapping_other_types
    return [] unless available?

    @overlapping_other_types ||= Jurisdiction.overlapping(@jurisdiction, on: @on)
      .where.not(jurisdictionable_type: @jurisdiction.jurisdictionable_type)
      .includes(:jurisdictionable)
      .limit(LIMIT)
      .map(&:jurisdictionable)
      .compact
      .sort_by { |record| [ record.model_name.human, record.name ] }
  end

  def members
    return [] unless available?

    [ member_for(@place, selected: true) ] + same_layer_neighbors.map { member_for(it, selected: false) }
  end

  def view_box
    return unless available?

    ids = [ selected_boundary.id ] + neighbor_boundary_ids
    box = ActiveRecord::Base.connection.select_value(ActiveRecord::Base.sanitize_sql_array([ <<~SQL.squish, TOLERANCE, ids ]))
      SELECT Box2D(ST_SimplifyPreserveTopology(ST_UnaryUnion(ST_Collect(geometry)), ?))::text
      FROM jurisdiction_boundaries
      WHERE id IN (?)
    SQL
    view_box_for(box)
  end

  def svg
    return unless available? && view_box

    paths = members.filter_map do |member|
      next unless member.path_data

      css = member.selected ? "is-selected" : "is-neighbor"
      %(<path class="#{css}" d="#{member.path_data}" />)
    end
    %(
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="#{view_box}" class="jurisdiction-outline-shape jurisdiction-neighborhood-shape" role="img" aria-label="#{ERB::Util.html_escape(@place.name)} and neighboring areas">
        <title>#{ERB::Util.html_escape(@place.name)} and same-layer neighbors</title>
        #{paths.join}
      </svg>
    ).squish
  end

  private

  def restrict_district_kind(scope)
    return scope unless @place.is_a?(District)

    scope.where(jurisdictionable_id: District.where(kind: @place.kind).select(:id))
  end

  def neighbor_boundary_ids
    return [] if same_layer_neighbors.empty?

    JurisdictionBoundary.effective_on(@on)
      .where(jurisdiction: Jurisdiction.where(jurisdictionable: same_layer_neighbors))
      .pluck(:id)
  end

  def member_for(record, selected:)
    jurisdiction = record.jurisdiction
    boundary = JurisdictionBoundary.effective_on(@on).where(jurisdiction: jurisdiction).order(:valid_from).first
    path = boundary && ActiveRecord::Base.connection.select_value(ActiveRecord::Base.sanitize_sql_array([
      "SELECT ST_AsSVG(ST_SimplifyPreserveTopology(geometry, ?), 0, 4) FROM jurisdiction_boundaries WHERE id = ?",
      TOLERANCE,
      boundary.id
    ]))
    Member.new(place: record, path_data: path, selected: selected)
  end

  def view_box_for(box_text)
    return unless box_text

    match = box_text.match(/BOX\(([-\d.]+) ([-\d.]+),([-\d.]+) ([-\d.]+)\)/)
    return unless match

    min_x, min_y, max_x, max_y = match.captures.map(&:to_f)
    width = max_x - min_x
    height = max_y - min_y
    pad_x = [ width, 0.01 ].max * PADDING_RATIO
    pad_y = [ height, 0.01 ].max * PADDING_RATIO
    [
      (min_x - pad_x).round(6),
      (-max_y - pad_y).round(6),
      (width + 2 * pad_x).round(6),
      (height + 2 * pad_y).round(6)
    ].join(" ")
  end
end
