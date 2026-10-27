# frozen_string_literal: true

require "net/http"

# Finds the point a street address stands on with the U.S. Census Bureau's geocoder, which needs no
# key and matches against the same TIGER/Line address ranges the boundaries come from. Nothing about
# the address is kept: the caller gets a Match or nil, and decides what to do with the point.
#
#   CensusGeocoder.locate("1600 Pennsylvania Ave NW, Washington, DC 20500")
#   # => #<data CensusGeocoder::Match latitude=38.8987, longitude=-77.0351, matched_address="1600 PENNSYLVANIA AVE NW, ...">
module CensusGeocoder
  Match = Data.define(:latitude, :longitude, :matched_address)

  # The geocoder couldn't be reached or answered with something other than a result.
  class Unavailable < StandardError; end

  ENDPOINT = URI("https://geocoding.geo.census.gov/geocoder/locations/onelineaddress")
  OPEN_TIMEOUT = 3
  READ_TIMEOUT = 8

  module_function

  # The best match for the address, or nil when the Census finds none.
  def locate(address)
    parse(fetch(address.to_s.squish))
  end

  def fetch(address)
    uri = ENDPOINT.dup
    uri.query = URI.encode_www_form(address: address, benchmark: "Public_AR_Current", format: "json")
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: OPEN_TIMEOUT, read_timeout: READ_TIMEOUT) { it.get(uri.request_uri) }
    raise Unavailable, "Census geocoder answered #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, SystemCallError, OpenSSL::SSL::SSLError => e
    raise Unavailable, e.message
  end

  def parse(body)
    match = JSON.parse(body).dig("result", "addressMatches")&.first or return
    Match.new(latitude: match.dig("coordinates", "y"), longitude: match.dig("coordinates", "x"), matched_address: match["matchedAddress"])
  rescue JSON::ParserError => e
    raise Unavailable, e.message
  end
end
