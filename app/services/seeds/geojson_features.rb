# frozen_string_literal: true

require "English"
require "zlib"

module Seeds
  # Reads GeoJSON features one at a time from a FeatureCollection (.json, .geojson), or from
  # newline-delimited GeoJSON (.geojsonl, .geojsons, .ndjson, .jsonl), either optionally gzipped, or from
  # a shapefile (.shp), which GDAL's ogr2ogr streams as newline-delimited GeoJSON in WGS 84. A
  # newline-delimited file or a shapefile is never held in memory whole.
  module GeojsonFeatures
    LINE_FORMATS = %w[.geojsonl .geojsons .ndjson .jsonl].freeze
    # GeoJSON text sequences (RFC 8142) begin each feature with a record separator.
    RECORD_SEPARATOR = "\u001E"

    module_function

    def each(path, &block)
      if File.extname(path.to_s) == ".shp" then each_shapefile_feature(path, &block)
      elsif line_delimited?(path) then each_line_feature(path, &block)
      else each_collection_feature(path, &block)
      end
    end

    def line_delimited?(path)
      LINE_FORMATS.include?(File.extname(path.to_s.delete_suffix(".gz")))
    end

    def each_line_feature(path, &block)
      open_file(path) { each_feature_line(it, &block) }
    end

    def each_shapefile_feature(path, &block)
      IO.popen([ "ogr2ogr", "-f", "GeoJSONSeq", "-t_srs", "EPSG:4326", "/vsistdout/", path.to_s ]) { each_feature_line(it, &block) }
      raise ArgumentError, "ogr2ogr couldn't read #{path}" unless $CHILD_STATUS.success?
    rescue Errno::ENOENT
      raise ArgumentError, "Reading shapefiles needs GDAL's ogr2ogr (brew install gdal)"
    end

    def each_feature_line(io)
      io.each_line do |line|
        line = line.delete(RECORD_SEPARATOR).strip
        yield JSON.parse(line) unless line.empty?
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
