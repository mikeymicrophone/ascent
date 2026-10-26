# frozen_string_literal: true

module Seeds
  # Checks that voters can be placed across the country once boundaries are imported. A point inside
  # every county must find a town or county in that county's state and exactly one district in each
  # legislative chamber, and a set of landmarks that are easy to get wrong must find the town expected.
  # A county's first point can land in a lake or bay, which districts leave out; the check then tries
  # other points inside the county for one on land, and only reports the county if none is.
  #
  #   Seeds::BoundaryCheck.new.run.problems
  class BoundaryCheck
    Landmark = Data.define(:label, :latitude, :longitude, :town)

    # Places that have caught bugs or are easy to get wrong, with the town each must find (nil for none).
    LANDMARKS = [
      Landmark.new("Las Vegas Strip, in unincorporated Paradise", 36.1147, -115.1728, "Clark County"),
      Landmark.new("Open land near Lewistown, Montana", 47.0, -109.5, "Fergus County"),
      Landmark.new("East Los Angeles, unincorporated", 34.0239, -118.1720, "Los Angeles County"),
      Landmark.new("Brooklyn", 40.6782, -73.9442, "New York"),
      Landmark.new("Staten Island", 40.5795, -74.1502, "New York"),
      # The District itself is DC's government; the Census lists Washington city as nonfunctioning.
      Landmark.new("Washington, DC", 38.8977, -77.0365, "District of Columbia"),
      Landmark.new("Richmond, an independent city", 37.5407, -77.4360, "Richmond"),
      Landmark.new("Baltimore, an independent city", 39.2904, -76.6122, "Baltimore"),
      Landmark.new("New Orleans, in a parish", 29.9511, -90.0715, "New Orleans"),
      Landmark.new("Anchorage, a consolidated borough", 61.2181, -149.9003, "Anchorage"),
      Landmark.new("Bristol, Tennessee", 36.5951, -82.1887, "Bristol"),
      Landmark.new("Bristol, Virginia", 36.6100, -82.1700, "Bristol"),
      Landmark.new("Kansas City, Kansas", 39.1142, -94.6275, "Kansas City"),
      Landmark.new("Cambridge, Massachusetts", 42.3736, -71.1097, "Cambridge"),
      Landmark.new("Hanover, New Hampshire", 43.7022, -72.2896, "Hanover"),
      Landmark.new("Maine's unorganized territory", 45.90, -69.50, "Piscataquis County"),
      Landmark.new("Canton Township, Michigan", 42.3086, -83.4822, "Canton"),
      Landmark.new("Greenwich, in a Connecticut planning region", 41.0262, -73.6282, "Greenwich"),
      Landmark.new("Chicago Loop", 41.8781, -87.6298, "Chicago"),
      Landmark.new("Syracuse City Hall", 43.0481, -76.1474, "Syracuse"),
      Landmark.new("Toronto, outside the country", 43.6532, -79.3832, nil)
    ].freeze

    # Other points tried inside a county whose first point falls in water.
    LAND_TRIES = 12

    attr_reader :problems, :counties_checked, :in_water, :town_kinds

    def initialize(landmarks: LANDMARKS)
      @landmarks = landmarks
      @problems = Hash.new { |hash, key| hash[key] = [] }
      @counties_checked = 0
      @in_water = []
      @town_kinds = Hash.new(0)
    end

    def run
      county_points.each { |boundary_id, name, state_code, longitude, latitude| check_county(boundary_id, name, state_code, longitude, latitude) }
      @landmarks.each { check_landmark(it) }
      self
    end

    def ok?
      problems.empty?
    end

    private

    def county_points
      ActiveRecord::Base.connection.select_rows(<<~SQL)
        SELECT jurisdiction_boundaries.id, counties.name, states.code, ST_X(point), ST_Y(point)
        FROM jurisdiction_boundaries
        JOIN jurisdictions ON jurisdictions.id = jurisdiction_boundaries.jurisdiction_id AND jurisdictions.jurisdictionable_type = 'County'
        JOIN counties ON counties.id = jurisdictions.jurisdictionable_id
        JOIN states ON states.id = counties.state_id
        CROSS JOIN LATERAL ST_PointOnSurface(jurisdiction_boundaries.geometry) point
        WHERE jurisdiction_boundaries.valid_until IS NULL
        ORDER BY states.code, counties.name
      SQL
    end

    def check_county(boundary_id, name, state_code, longitude, latitude)
      @counties_checked += 1
      place = "#{name}, #{state_code}"
      counts = chamber_counts(longitude, latitude)
      unless every_chamber?(counts, state_code)
        land = other_points(boundary_id).find { every_chamber?(chamber_counts(*it), state_code) }
        if land
          @in_water << place
          longitude, latitude = land
          counts = chamber_counts(longitude, latitude)
        end
      end

      town = claim(latitude, longitude).town
      @town_kinds[town&.jurisdictionable_type || "none"] += 1
      problems[:no_town] << place unless town
      problems[:wrong_state] << "#{place} found #{town.name}" if town && state_code_of(town) != state_code
      counts.each do |chamber, count|
        expected = expected_districts(chamber, state_code)
        problems[:"#{chamber}_districts"] << "#{place} is in #{count}, expected #{expected}" unless count == expected
      end
    end

    def every_chamber?(counts, state_code)
      counts.all? { |chamber, count| count >= expected_districts(chamber, state_code) }
    end

    def other_points(boundary_id)
      ActiveRecord::Base.connection.select_rows(<<~SQL.squish, "Boundary check", [ boundary_id ])
        SELECT ST_X(point), ST_Y(point)
        FROM jurisdiction_boundaries, ST_Dump(ST_GeneratePoints(geometry, #{LAND_TRIES}, 1)) AS dumped(path, point)
        WHERE jurisdiction_boundaries.id = $1
      SQL
    end

    def check_landmark(landmark)
      found = claim(landmark.latitude, landmark.longitude).town&.name
      problems[:landmarks] << "#{landmark.label} found #{found || "nothing"}, expected #{landmark.town || "nothing"}" unless found == landmark.town
    end

    def claim(latitude, longitude)
      ResidenceClaim.new(latitude: latitude, longitude: longitude)
    end

    def chamber_counts(longitude, latitude)
      kinds = District.where(id: Jurisdiction.covering(longitude, latitude).where(jurisdictionable_type: "District").select(:jurisdictionable_id)).pluck(:kind)
      District::CHAMBER_KINDS.transform_values { |chamber_kinds| kinds.count { chamber_kinds.include?(it) } }
    end

    # Nebraska has a single chamber, and DC has no legislature.
    def expected_districts(chamber, state_code)
      return 0 if chamber == "state_house" && state_code == "NE"
      return 0 if chamber != "congressional" && state_code == "DC"

      1
    end

    def state_code_of(town)
      town.self_and_ancestors.find_by(jurisdictionable_type: "State")&.jurisdictionable&.code
    end
  end
end
