# frozen_string_literal: true

require "zlib"

module Seeds
  # Reads GeoJSON features one at a time from a FeatureCollection (.json, .geojson), or from
  # newline-delimited GeoJSON (.geojsonl, .geojsons, .ndjson, .jsonl), either optionally gzipped. Use the
  # newline-delimited form for nationwide TIGER layers, so a file is never held in memory whole:
  #
  #   ogr2ogr -f GeoJSONSeq tl_2025_us_county.geojsonl tl_2025_us_county.shp
  module GeojsonFeatures
    LINE_FORMATS = %w[.geojsonl .geojsons .ndjson .jsonl].freeze
    # GeoJSON text sequences (RFC 8142) begin each feature with a record separator.
    RECORD_SEPARATOR = "\u001E"

    module_function

    def each(path, &block)
      line_delimited?(path) ? each_line_feature(path, &block) : each_collection_feature(path, &block)
    end

    def line_delimited?(path)
      LINE_FORMATS.include?(File.extname(path.to_s.delete_suffix(".gz")))
    end

    def each_line_feature(path)
      open_file(path) do |io|
        io.each_line do |line|
          line = line.delete(RECORD_SEPARATOR).strip
          yield JSON.parse(line) unless line.empty?
        end
      end
    end

    def each_collection_feature(path, &block)
      document = open_file(path) { JSON.parse(it.read) }
      document["type"] == "FeatureCollection" ? document["features"].each(&block) : yield(document)
    end

    def open_file(path, &block)
      path.to_s.end_with?(".gz") ? Zlib::GzipReader.open(path, &block) : File.open(path, &block)
    end
  end
end
