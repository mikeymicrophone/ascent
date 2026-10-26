# frozen_string_literal: true

module Seeds
  # Imports boundaries from Census TIGER/Line shapefiles or GeoJSON. Each feature is matched to a
  # jurisdiction: first by the census ID a previous import recorded, else by name within its state, after
  # which the census ID is recorded for next time. Towns and counties are never created, but a
  # congressional or state legislative district missing from the seed data is, under its state, since
  # the Census Bureau's list of them is complete. Its geometry becomes
  # the jurisdiction's boundary from January 1 of the file's vintage: a re-import of the same vintage
  # replaces it, and a newer vintage closes the older boundary where the new one begins.
  #
  # TIGER/Line geometry is NAD83 (EPSG:4269). Shapefiles are reprojected to WGS 84 (SRID 4326) as they
  # are read; GeoJSON is taken as WGS 84 already, which differs from NAD83 by about a meter in the
  # contiguous states, well inside what a residence lookup needs.
  #
  #   Seeds::TigerBoundaryImporter.new(vintage: 2025).import("tl_2025_us_county.shp")
  class TigerBoundaryImporter
    # Lower chambers go by other names in some states: the Assembly, or the House of Delegates. Nebraska
    # has a single chamber, whose districts TIGER files as upper.
    LOWER_CHAMBERS = { "Assembly District" => %w[CA NV NJ NY WI], "House of Delegates District" => %w[MD VA WV] }.freeze
    UPPER_CHAMBERS = { "Legislative District" => %w[NE] }.freeze
    SAMPLE_LIMIT = 25
    # TIGER/Line file layers in the order to import them: towns match within counties already imported.
    LAYER_ORDER = %w[_state _county _cousub _place _cd _sldu _sldl].freeze

    attr_reader :vintage, :report

    def initialize(vintage:, dry_run: false)
      @vintage = Integer(vintage)
      @dry_run = dry_run
      @factory = RGeo::Geos.factory(srid: 4326)
      @report = { matched: 0, written: 0, created: 0, skipped: 0, placed_elsewhere: 0, unmatched_count: 0, ambiguous_count: 0, invalid_count: 0,
                  unmatched: [], ambiguous: [], invalid: [] }
      @states = {}
      @legislative_districts = {}
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

      state = state_of(feature)
      candidates = matching_jurisdictions(feature, state)
      return count(:placed_elsewhere) if candidates.empty? && named_jurisdictions(feature, state).any?
      return sample(:unmatched, feature) if candidates.empty? && !(state && feature.district?)
      return sample(:ambiguous, feature) if candidates.many?

      geometry = multi_polygon(feature)
      return sample(:invalid, feature) unless geometry

      candidates.any? ? count(:matched) : count(:created)
      write(candidates.first, feature, geometry, state) unless @dry_run
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

    def state_of(feature)
      @states.fetch(feature.state_postal_code) do
        @states[feature.state_postal_code] = State.where(country: Country.where(code: "US")).with_postal_code(feature.state_postal_code).first
      end
    end

    # The jurisdiction a previous import recorded for this feature, else those whose place matches by
    # name and that no other feature has claimed, so a village never takes the shape of a same-named town.
    def matching_jurisdictions(feature, state)
      recorded = Jurisdiction.with_census_id(feature.census_class, feature.geoid).to_a
      return recorded if recorded.any? || state.nil?

      unclaimed = owners(feature, state).includes(:jurisdiction).select { it.jurisdiction && it.jurisdiction.census_geoid.nil? }
      of_legal_type(unclaimed, feature).map(&:jurisdiction)
    end

    # Every jurisdiction the feature's name matches, whether or not another feature has claimed it.
    def named_jurisdictions(feature, state)
      state ? owners(feature, state).includes(:jurisdiction).filter_map(&:jurisdiction) : []
    end

    # Where a town and a village share a name, the seed codes tell them apart: BARRE_CITY, BARRE_TOWN.
    def of_legal_type(owners, feature)
      return owners unless owners.many? && feature.legal_type

      suffix = "_#{feature.legal_type.upcase.gsub(/\W+/, "_")}"
      owners.select { it.entity_code.to_s.end_with?(suffix) }.presence || owners
    end

    def owners(feature, state)
      case feature.kind
      when :state then State.where(id: state.id)
      when :county then County.in_state(state).named(feature.full_name, feature.name)
      when :place then Municipality.in_state(state).named(feature.name)
      when :county_subdivision then county_subdivisions(feature, state)
      when :congressional_district then District.of_chamber("congressional").named(congressional_name(feature, state))
      when :upper_district, :lower_district then legislative_districts(feature, state)
      end
    end

    # The state's districts in the feature's chamber whose label reads the same, however it is spelled.
    def legislative_districts(feature, state)
      chamber = feature.kind == :upper_district ? "state_senate" : "state_house"
      by_label = @legislative_districts[[ state.id, chamber ]] ||=
        District.of_chamber(chamber).where("districts.name LIKE ?", "#{state.name} %").to_a
          .group_by { DistrictLabel.key(it.name.delete_prefix(state.name)) }
      District.where(id: by_label.fetch(DistrictLabel.key(feature.district_label), []))
    end

    def create_district(feature, state)
      kind, name = district_kind_and_name(feature, state)
      District.create!(kind: kind, name: name).create_jurisdiction!(parent: state.jurisdiction)
    end

    def district_kind_and_name(feature, state)
      case feature.kind
      when :congressional_district then [ "congressional district", congressional_name(feature, state) ]
      when :upper_district then [ "state senate district", "#{state.name} #{chamber_name(UPPER_CHAMBERS, "State Senate District", state)} #{feature.district_label}" ]
      when :lower_district
        chamber_name(LOWER_CHAMBERS, "State House District", state).then { [ it.downcase, "#{state.name} #{it} #{feature.district_label}" ] }
      end
    end

    def chamber_name(names, default, state)
      names.find { |_, codes| codes.include?(state.code) }&.first || default
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

    def write(jurisdiction, feature, geometry, state)
      ActiveRecord::Base.transaction do
        jurisdiction ||= create_district(feature, state)
        jurisdiction.update!(census_class: feature.census_class, census_geoid: feature.geoid) unless jurisdiction.census_geoid
        jurisdiction.update!(parent: state.jurisdiction) if feature.district? && jurisdiction.parent_id.nil? && state&.jurisdiction
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
