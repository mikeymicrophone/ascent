# frozen_string_literal: true

module Seeds
  # Imports boundaries from Census TIGER/Line files exported as GeoJSON. Each feature is matched to an
  # existing jurisdiction (never creating one): first by the census ID a previous import recorded, else
  # by name within its state, after which the census ID is recorded for next time. Its geometry becomes
  # the jurisdiction's boundary from January 1 of the file's vintage: a re-import of the same vintage
  # replaces it, and a newer vintage closes the older boundary where the new one begins.
  #
  # TIGER/Line geometry is NAD83 (EPSG:4269); it is stored as WGS 84 (SRID 4326), which differs by
  # about a meter in the contiguous states, well inside what a residence lookup needs.
  #
  #   Seeds::TigerBoundaryImporter.new(vintage: 2025).import("tl_2025_us_county.geojsonl")
  class TigerBoundaryImporter
    # Lower-chamber district names differ by state: State House, Assembly, House of Delegates.
    LOWER_CHAMBER_NAMES = [ "State House District", "Assembly District", "House of Delegates District" ].freeze
    SAMPLE_LIMIT = 25
    # TIGER/Line file layers in the order to import them: towns match within counties already imported.
    LAYER_ORDER = %w[_state _county _cousub _place _cd _sldu _sldl].freeze

    attr_reader :vintage, :report

    def initialize(vintage:, dry_run: false)
      @vintage = Integer(vintage)
      @dry_run = dry_run
      @factory = RGeo::Geos.factory(srid: 4326)
      @report = { matched: 0, written: 0, skipped: 0, unmatched_count: 0, ambiguous_count: 0, invalid_count: 0,
                  unmatched: [], ambiguous: [], invalid: [] }
    end

    def valid_from
      Date.new(vintage, 1, 1)
    end

    def import(path)
      GeojsonFeatures.each(path) { import_feature(TigerFeature.new(it)) }
      report
    end

    # Several files, such as every layer for one state, states and counties first.
    def import_all(paths)
      paths.sort_by { |path| [ LAYER_ORDER.index { File.basename(path).include?(it) } || LAYER_ORDER.size, path ] }.each { import(it) }
      report
    end

    def import_feature(feature)
      return count(:skipped) unless feature.kind

      candidates = matching_jurisdictions(feature)
      return sample(:unmatched, feature) if candidates.empty?
      return sample(:ambiguous, feature) if candidates.many?

      geometry = multi_polygon(feature)
      return sample(:invalid, feature) unless geometry

      count(:matched)
      write(candidates.first, feature, geometry) unless @dry_run
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
      sample(:invalid, feature, e.message)
    end

    private

    def count(key)
      @report[key] += 1
    end

    def sample(key, feature, reason = nil)
      @report[key] << [ feature.label, reason ].compact.join(": ") if @report[key].size < SAMPLE_LIMIT
      count(:"#{key}_count")
    end

    # The jurisdiction a previous import recorded for this feature, else those whose place matches by name.
    def matching_jurisdictions(feature)
      recorded = Jurisdiction.with_census_id(feature.census_class, feature.geoid).to_a
      return recorded if recorded.any?

      state = State.where(country: Country.where(code: "US")).with_postal_code(feature.state_postal_code).first
      return [] unless state

      owners(feature, state).includes(:jurisdiction).filter_map(&:jurisdiction)
    end

    def owners(feature, state)
      case feature.kind
      when :state then State.where(id: state.id)
      when :county then County.in_state(state).named(feature.full_name, feature.name)
      when :place then Municipality.in_state(state).named(feature.name)
      when :county_subdivision then county_subdivisions(feature, state)
      when :congressional_district then District.named(congressional_name(feature, state))
      when :upper_district then District.named("#{state.name} State Senate District #{feature.district_number}")
      when :lower_district then District.named(LOWER_CHAMBER_NAMES.map { "#{state.name} #{it} #{feature.district_number}" })
      end
    end

    # A town in New England, matched within its county when the county's boundary is already imported.
    def county_subdivisions(feature, state)
      towns = Municipality.in_state(state).named(feature.name)
      county = Jurisdiction.with_census_id("G4020", feature.county_geoid).first&.jurisdictionable
      county ? towns.where(county: county) : towns
    end

    def congressional_name(feature, state)
      feature.at_large? ? "#{state.name} At-Large Congressional District" : "#{state.name} Congressional District #{feature.district_number}"
    end

    # The feature's shape as a valid MultiPolygon, repaired if needed, or nil when nothing usable remains.
    def multi_polygon(feature)
      geometry = RGeo::GeoJSON.decode(feature.geometry_json, geo_factory: @factory)
      geometry = geometry.make_valid unless geometry.valid?
      polygons = polygons_in(geometry)
      @factory.multi_polygon(polygons) if polygons.any?
    rescue RGeo::Error::RGeoError
      nil
    end

    def polygons_in(geometry)
      case geometry
      when RGeo::Feature::Polygon then [ geometry ]
      when RGeo::Feature::GeometryCollection then geometry.flat_map { polygons_in(it) }
      else []
      end
    end

    def write(jurisdiction, feature, geometry)
      ActiveRecord::Base.transaction do
        jurisdiction.update!(census_class: feature.census_class, census_geoid: feature.geoid) unless jurisdiction.census_geoid
        write_boundary(jurisdiction, geometry)
      end
      count(:written)
    end

    # The same vintage replaces its boundary; a newer one closes whatever was in force when it begins,
    # and an older one ends where a later boundary already starts.
    def write_boundary(jurisdiction, geometry)
      same_vintage = jurisdiction.boundaries.find_by(valid_from: valid_from)
      return same_vintage.update!(geometry: geometry) if same_vintage

      jurisdiction.boundaries.effective_on(valid_from).update_all(valid_until: valid_from)
      later = jurisdiction.boundaries.where("valid_from > ?", valid_from).minimum(:valid_from)
      jurisdiction.boundaries.create!(geometry: geometry, valid_from: valid_from, valid_until: later)
    end
  end
end
