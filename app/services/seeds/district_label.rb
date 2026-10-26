# frozen_string_literal: true

module Seeds
  # A legislative district's label reduced to a key that reads the same however a source spells it:
  # "Massachusetts State House District: Thirty-Fifth Middlesex" and TIGER's "35th Middlesex District"
  # both become "35 middlesex"; "Cape & Islands" and "Cape and Islands District" both "cape islands".
  module DistrictLabel
    ORDINALS = %w[first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelfth thirteenth
                  fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth].each.with_index(1).to_h
                 .merge("twentieth" => 20, "thirtieth" => 30, "fortieth" => 40).freeze
    TENS = { "twenty" => 20, "thirty" => 30, "forty" => 40 }.freeze
    ORDINAL_WORDS = /\b(?:(#{TENS.keys.join("|")})-)?(#{ORDINALS.keys.join("|")})\b/
    # Words that name the chamber or the kind of area, not the district itself.
    CHAMBER_WORDS = /\b(?:state|house|senate|senatorial|assembly|legislative|of|delegates?|(?:sub)?districts?|and)\b/

    module_function

    def key(label)
      label.downcase.gsub(ORDINAL_WORDS) { (TENS.fetch($1, 0) + ORDINALS.fetch($2)).to_s }
        .gsub(/\b(\d+)(?:st|nd|rd|th)\b/, '\1').gsub(CHAMBER_WORDS, " ")
        .gsub(/[^a-z0-9]+/, " ").gsub(/\b0+(?=\d)/, "").squish
    end
  end
end
