# frozen_string_literal: true

class MapExplorer
  include Rails.application.routes.url_helpers

  LAYERS = {
    "counties" => "Counties",
    "congressional" => "Congressional districts",
    "state_senate" => "State senate districts",
    "state_house" => "State house / assembly districts"
  }.freeze

  LAYER_STYLES = {
    "counties" => { color: "#6a765c", fill: "#dce7c8" },
    "congressional" => { color: "#1d4f91", fill: "#c5d8f0" },
    "state_senate" => { color: "#8a4b1f", fill: "#f0dcc5" },
    "state_house" => { color: "#5b3d7a", fill: "#e0d0f0" }
  }.freeze

  attr_reader :state, :layers, :on

  def initialize(state: nil, layer: nil, layers: nil, on: Date.current)
    @state = state
    @on = on
    @layers = normalize_layers(layer, layers)
  end

  def layer
    layers.first || "counties"
  end

  def states
    State.joins(:country).where(countries: { code: "US" }).order(:name, :id)
  end

  def records_for(layer_key)
    return states unless state

    case layer_key
    when "counties" then County.where(state: state).order(:name, :id)
    else District.of_chamber(layer_key).in_state(state).order(:name, :id)
    end
  end

  def records
    @records ||= state ? layers.flat_map { records_for(it).to_a }.uniq : states.to_a
  end

  def record_path(record)
    state ? polymorphic_path(record) : map_path(state_id: record.id)
  end

  def label
    return "States" unless state
    return LAYERS.fetch(layer) if layers.size == 1

    layers.map { LAYERS.fetch(it) }.to_sentence
  end

  def layer_status
    return [] unless state

    LAYERS.keys.map do |key|
      places = records_for(key)
      mapped = features_for(places, tolerance: 0.002, layer_key: key)
      {
        key: key,
        label: LAYERS.fetch(key),
        selected: layers.include?(key),
        record_count: places.size,
        feature_count: mapped.size,
        available: mapped.any?,
        style: LAYER_STYLES.fetch(key)
      }
    end
  end

  def unavailable_layers
    layer_status.select { |entry| entry[:selected] && !entry[:available] }
  end

  def feature_collection
    Rails.cache.fetch(cache_key, expires_in: 12.hours) { build_feature_collection }
  end

  def cache_key
    [
      "map_explorer/v2",
      state&.id || "us",
      layers.join(","),
      @on.iso8601,
      JurisdictionBoundary.count,
      JurisdictionBoundary.maximum(:updated_at)&.utc&.iso8601(6)
    ]
  end


  private

  def normalize_layers(layer, layers)
    values = Array(layers).flatten.compact_blank
    values = [ layer.presence || "counties" ] if values.empty?
    values = values.map(&:to_s).uniq
    unknown = values - LAYERS.keys
    raise ActiveRecord::RecordNotFound, "Unknown map layer" if unknown.any?

    values
  end

  def build_feature_collection
    if state
      layer_groups = layers.map do |key|
        features = features_for(records_for(key), tolerance: 0.002, layer_key: key)
        {
          key: key,
          label: LAYERS.fetch(key),
          style: LAYER_STYLES.fetch(key),
          features: features,
          available: features.any?
        }
      end
      features = layer_groups.flat_map { it[:features] }
      outline = features_for(State.where(id: state.id), tolerance: 0.002).first
      {
        type: "FeatureCollection",
        features: features,
        layers: layer_groups,
        unavailable_layers: unavailable_layers.map { it.slice(:key, :label, :record_count, :feature_count) },
        legend: layer_groups.map { |group|
          group.slice(:key, :label, :style, :available).merge(feature_count: group[:features].size)
        },
        outline: outline,
        vintages: (features + [ outline ].compact).map { it[:properties][:boundary_year] }.uniq.sort
      }
    else
      features = features_for(states, tolerance: 0.03)
      {
        type: "FeatureCollection",
        features: features,
        layers: [],
        unavailable_layers: [],
        legend: [],
        outline: nil,
        vintages: features.map { it[:properties][:boundary_year] }.uniq.sort
      }
    end
  end

  def features_for(places, tolerance:, layer_key: nil)
    places = places.to_a
    return [] if places.empty?

    by_id = places.index_by(&:id)
    boundaries = JurisdictionBoundary.effective_on(@on)
      .where(jurisdiction: Jurisdiction.where(jurisdictionable: places)).joins(:jurisdiction)
    boundaries.order(:jurisdiction_id).pluck(
      "jurisdictions.jurisdictionable_id",
      :valid_from,
      Arel.sql("ST_AsGeoJSON(ST_SimplifyPreserveTopology(jurisdiction_boundaries.geometry, #{tolerance}))")
    ).map do |id, valid_from, geometry|
      record = by_id.fetch(id)
      properties = {
        name: record.name,
        url: record_path(record),
        state_code: state&.code || record.code,
        boundary_year: valid_from.year
      }
      properties[:layer] = layer_key if layer_key
      properties[:layer_label] = LAYERS.fetch(layer_key) if layer_key
      {
        type: "Feature",
        id: "#{record.model_name.singular}-#{id}",
        properties: properties,
        geometry: JSON.parse(geometry)
      }
    end
  end
end
