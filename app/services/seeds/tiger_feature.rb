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

    # Functional status codes for areas with no government of their own: fictitious, inactive,
    # nonfunctioning, and statistical (such as census county divisions).
    NOT_GOVERNMENTS = %w[F I N S].freeze
    TOWN_KINDS = %i[county_subdivision place].freeze

    # The parts of a legislative district's legal name that say which chamber it belongs to.
    LEGISLATIVE_WORDS = /\b(?:State (?:House|Senate|Legislative) (?:Sub)?district|Assembly District|Delegate District|Senatorial District|District)\b/i

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
      CLASSES[census_class] unless undefined_district? || undefined_subdivision? || council_ward? || not_a_government?
    end

    # A county subdivision or place that has no government, such as "Las Vegas CCD", is never a town.
    def not_a_government?
      TOWN_KINDS.include?(CLASSES[census_class]) && NOT_GOVERNMENTS.include?(properties["FUNCSTAT"])
    end

    def district?
      kind.to_s.end_with?("district")
    end

    # Water and other areas a state leaves outside every district, coded ZZ or ZZZ.
    def undefined_district?
      district_code&.match?(/\AZ+\z/)
    end

    # Water and other parts of a county outside every town, coded 00000.
    def undefined_subdivision?
      properties["COUSUBFP"] == "00000"
    end

    # DC has no legislature; its upper-chamber layer holds the council's wards.
    def council_ward?
      census_class == "G5210" && state_fips == "11"
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

    # The kind of government a town is, from its legal name: "town", "city", "village", "borough".
    def legal_type
      full_name.delete_prefix(name.to_s).strip.presence if properties["NAMELSAD"] && name
    end

    def district_code
      properties[congressional_key] || properties["SLDUST"] || properties["SLDLST"]
    end

    # A district's number without leading zeros ("07" reads 7), or its code as given ("1A", "C13").
    def district_number
      district_code&.match?(/\A\d+\z/) ? district_code.to_i.to_s : district_code
    end

    # How the district is known, from its legal name without the chamber: "30", "29A", "Grafton 15",
    # "Chittenden-13", "3rd Barnstable". Files without names fall back to the number.
    def district_label
      label = properties["NAMELSAD"].to_s.gsub(LEGISLATIVE_WORDS, "").squish
      label.match?(/\A\d/) ? label.sub(/\A0+(?=\d)/, "") : label.presence || district_number
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
