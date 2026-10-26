# frozen_string_literal: true

module Seeds
  # One feature from a TIGER/Line file exported as GeoJSON: its feature class, GEOID, state, name and,
  # for districts, number, read from the Census Bureau's own attribute names in any letter case.
  class TigerFeature
    # Feature classes (MTFCC) the importer knows how to place, and what each one is.
    CLASSES = {
      "G4000" => :state,
      "G4020" => :county,
      "G4040" => :county_subdivision,
      "G4110" => :place,
      "G5200" => :congressional_district,
      "G5210" => :upper_district,
      "G5220" => :lower_district
    }.freeze

    # Congressional district numbers TIGER uses for a state's single at-large seat.
    AT_LARGE = %w[00 98].freeze

    # State FIPS codes to postal codes, for files that carry only STATEFP.
    STATE_POSTAL_CODES = {
      "01" => "AL", "02" => "AK", "04" => "AZ", "05" => "AR", "06" => "CA", "08" => "CO", "09" => "CT", "10" => "DE",
      "11" => "DC", "12" => "FL", "13" => "GA", "15" => "HI", "16" => "ID", "17" => "IL", "18" => "IN", "19" => "IA",
      "20" => "KS", "21" => "KY", "22" => "LA", "23" => "ME", "24" => "MD", "25" => "MA", "26" => "MI", "27" => "MN",
      "28" => "MS", "29" => "MO", "30" => "MT", "31" => "NE", "32" => "NV", "33" => "NH", "34" => "NJ", "35" => "NM",
      "36" => "NY", "37" => "NC", "38" => "ND", "39" => "OH", "40" => "OK", "41" => "OR", "42" => "PA", "44" => "RI",
      "45" => "SC", "46" => "SD", "47" => "TN", "48" => "TX", "49" => "UT", "50" => "VT", "51" => "VA", "53" => "WA",
      "54" => "WV", "55" => "WI", "56" => "WY", "60" => "AS", "66" => "GU", "69" => "MP", "72" => "PR", "78" => "VI"
    }.freeze

    attr_reader :properties, :geometry_json

    def initialize(feature)
      @properties = feature.fetch("properties", {}).transform_keys(&:upcase)
      @geometry_json = feature["geometry"]
    end

    def census_class
      properties["MTFCC"]
    end

    def kind
      CLASSES[census_class]
    end

    def geoid
      properties["GEOID"] || properties["GEOIDFQ"]&.split("US")&.last
    end

    def state_fips
      properties["STATEFP"] || geoid&.first(2)
    end

    def state_postal_code
      properties["STUSPS"] || STATE_POSTAL_CODES[state_fips]
    end

    def county_geoid
      "#{state_fips}#{properties["COUNTYFP"]}" if properties["COUNTYFP"]
    end

    def name
      properties["NAME"]
    end

    # The name with its legal description, such as "Accomack County" or "Baltimore city".
    def full_name
      properties["NAMELSAD"] || name
    end

    # A district's number without leading zeros ("07" reads 7), or its code as given ("1A", "Chittenden-1").
    def district_number
      code = properties[congressional_key] || properties["SLDUST"] || properties["SLDLST"]
      code&.match?(/\A\d+\z/) ? code.to_i.to_s : code
    end

    def at_large?
      AT_LARGE.include?(properties[congressional_key])
    end

    # Files name the congressional field for their Congress, such as CD119FP.
    def congressional_key
      properties.keys.find { it.match?(/\ACD\d+FP\z/) }
    end

    def label
      "#{census_class} #{geoid} #{full_name} (#{state_postal_code})"
    end
  end
end
