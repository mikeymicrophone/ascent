# frozen_string_literal: true

# A display-only outline of one jurisdiction's effective boundary.
# Builds SVG (and optional PNG) from a simplified PostGIS copy; stored geometry is never changed.
class BoundaryOutline
  PLACE_TYPES = %w[State County District Municipality Country].freeze

  DETAIL = {
    panel: { tolerance: 0.002, padding_ratio: 0.08, png_width: 640 },
    compact: { tolerance: 0.01, padding_ratio: 0.12, png_width: 160 }
  }.freeze

  attr_reader :place, :detail_key, :on


  def self.for(record, on: Date.current, detail: :panel)
    new(record, on: on, detail: detail)
  end

  def initialize(record, on: Date.current, detail: :panel)
    @on = on
    @detail_key = detail
    @settings = DETAIL.fetch(detail)
    @place, @jurisdiction = resolve(record)
  end

  def available?
    boundary.present? && path_data.present? && view_box.present?
  end

  def missing?
    !available?
  end

  def vintage_year
    boundary&.valid_from&.year
  end

  def name
    place&.name
  end

  def path_data
    return @path_data if defined?(@path_data)

    @path_data = cached_geometry_parts[:path]
  end

  def view_box
    return @view_box if defined?(@view_box)

    @view_box = cached_geometry_parts[:view_box]
  end

  def svg(title: name, css_class: "jurisdiction-outline-shape")
    return unless available?

    %(
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="#{view_box}" class="#{css_class}" role="img" aria-label="#{escape(title)} outline">
        <title>#{escape(title)} boundary</title>
        <path d="#{path_data}" />
      </svg>
    ).squish
  end

  def png(width: @settings.fetch(:png_width))
    return unless available?

    require "open3"
    bytes, error, status = Open3.capture3(
      RbConfig.ruby,
      Rails.root.join("script/render_svg_to_png").to_s,
      stdin_data: svg_document_for_png(width),
      binmode: true
    )
    raise "boundary outline PNG render failed: #{error}" unless status.success?

    bytes
  end


  def multipart?
    return false unless available?

    geometry_value("ST_NumGeometries(geometry)", with_tolerance: false).to_i > 1
  end

  def has_holes?
    return false unless available?

    geometry_value(<<~SQL.squish, with_tolerance: false).to_i.positive?
      (SELECT COALESCE(SUM(ST_NRings(geom) - 1), 0)
       FROM ST_Dump(geometry) AS dump(path, geom))
    SQL
  end

  private

  def resolve(record)
    case record
    when Jurisdiction
      [ record.jurisdictionable, record ]
    when Office
      jurisdiction = record.jurisdiction
      [ jurisdiction&.jurisdictionable, jurisdiction ]
    when Race
      resolve(record.office)
    else
      if record.respond_to?(:jurisdiction)
        [ record, record.jurisdiction ]
      else
        [ nil, nil ]
      end
    end
  end

  def boundary
    return @boundary if defined?(@boundary)

    @boundary = @jurisdiction &&
      JurisdictionBoundary.effective_on(@on).where(jurisdiction: @jurisdiction).order(:valid_from).first
  end

  def cached_geometry_parts
    return @cached_geometry_parts if defined?(@cached_geometry_parts)
    return @cached_geometry_parts = { path: nil, view_box: nil } unless boundary

    @cached_geometry_parts = Rails.cache.fetch(outline_cache_key, expires_in: 12.hours) do
      path = geometry_value("ST_AsSVG(ST_SimplifyPreserveTopology(geometry, ?), 0, 4)")
      box = geometry_value("Box2D(ST_SimplifyPreserveTopology(geometry, ?))::text")
      { path: path, view_box: box && view_box_for(box) }
    end
  end

  def outline_cache_key
    [
      "boundary_outline/v1",
      boundary.id,
      @detail_key,
      boundary.updated_at.utc.to_fs(:number)
    ]
  end

  def geometry_value(expression, with_tolerance: true)
    return unless boundary

    sql = if with_tolerance
      ActiveRecord::Base.sanitize_sql_array([
        "SELECT #{expression} FROM jurisdiction_boundaries WHERE id = ?",
        @settings.fetch(:tolerance),
        boundary.id
      ])
    else
      ActiveRecord::Base.sanitize_sql_array([
        "SELECT #{expression} FROM jurisdiction_boundaries WHERE id = ?",
        boundary.id
      ])
    end
    ActiveRecord::Base.connection.select_value(sql)
  end

  def view_box_for(box_text)
    match = box_text.match(/BOX\(([-\d.]+) ([-\d.]+),([-\d.]+) ([-\d.]+)\)/)
    return unless match

    min_x, min_y, max_x, max_y = match.captures.map(&:to_f)
    width = max_x - min_x
    height = max_y - min_y
    pad_x = [ width, 0.01 ].max * @settings.fetch(:padding_ratio)
    pad_y = [ height, 0.01 ].max * @settings.fetch(:padding_ratio)
    [
      (min_x - pad_x).round(6),
      (-max_y - pad_y).round(6),
      (width + 2 * pad_x).round(6),
      (height + 2 * pad_y).round(6)
    ].join(" ")
  end

  def svg_document_for_png(width)
    %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="#{view_box}" width="#{width}" height="#{width}">
      <rect x="-10000" y="-10000" width="20000" height="20000" fill="#edf2e7"/>
      <path d="#{path_data}" fill="#dce7c8" stroke="#6a765c" stroke-width="0.015" stroke-linejoin="round"/>
    </svg>)
  end

  def escape(text)
    ERB::Util.html_escape(text.to_s)
  end
end
