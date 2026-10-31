# frozen_string_literal: true

namespace :gis do
  desc "Report map GeoJSON and outline payload sizes for development measurements: bin/rails gis:map_payload_report STATE=NY"
  task map_payload_report: :environment do
    on = Date.current
    us = MapExplorer.new(on: on)
    us_json = us.feature_collection.to_json
    puts "US overview: features=#{us.feature_collection[:features].size} bytes=#{us_json.bytesize} cache_key=#{us.cache_key.join('/')}"

    code = ENV.fetch("STATE", "NY")
    state = State.joins(:country).where(countries: { code: "US" }, code: code).first!
    MapExplorer::LAYERS.keys.each { |layer| report_state(state, [ layer ], on) }
    report_state(state, %w[counties congressional], on)
    report_state(state, MapExplorer::LAYERS.keys, on)


    if state.jurisdiction
      outline = BoundaryOutline.for(state)
      if outline.available?
        svg = outline.svg.to_s
        png = outline.png
        puts "State outline #{state.code}: svg_bytes=#{svg.bytesize} png_bytes=#{png&.bytesize} vintage=#{outline.vintage_year}"
      else
        puts "State outline #{state.code}: unavailable"
      end
    end
  end
end

def report_state(state, layers, on)
  explorer = MapExplorer.new(state: state, layers: layers, on: on)
  payload = explorer.feature_collection
  json = payload.to_json
  puts "#{state.code} layers=#{layers.join('+')}: features=#{payload[:features].size} " \
       "unavailable=#{payload[:unavailable_layers].map { it[:key] }.join(',')} bytes=#{json.bytesize}"
end
