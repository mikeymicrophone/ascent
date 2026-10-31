class MapExplorer
  include Rails.application.routes.url_helpers

  LAYERS = {
    "counties" => "Counties", "congressional" => "Congressional districts",
    "state_senate" => "State senate districts", "state_house" => "State house / assembly districts"
  }.freeze

  attr_reader :state, :layer

  def initialize(state: nil, layer: "counties", on: Date.current)
    @state, @layer, @on = state, layer, on
  end

  def states
    State.joins(:country).where(countries: { code: "US" }).order(:name, :id)
  end

  def records
    @records ||= if !state
      states
    elsif layer == "counties"
      County.where(state: state).order(:name, :id)
    else
      District.of_chamber(layer).in_state(state).order(:name, :id)
    end
  end

  def record_path(record)
    state ? polymorphic_path(record) : map_path(state_id: record.id)
  end

  def label
    state ? LAYERS.fetch(layer) : "States"
  end

  def feature_collection
    features = features_for(records, tolerance: state ? 0.002 : 0.03)
    outline = features_for(State.where(id: state.id), tolerance: 0.002).first if state
    { type: "FeatureCollection", features: features, outline: outline,
      vintages: (features + [ outline ].compact).map { it[:properties][:boundary_year] }.uniq.sort }
  end

  private

  def features_for(places, tolerance:)
    by_id = places.index_by(&:id)
    boundaries = JurisdictionBoundary.effective_on(@on)
      .where(jurisdiction: Jurisdiction.where(jurisdictionable: places)).joins(:jurisdiction)
    boundaries.order(:jurisdiction_id).pluck("jurisdictions.jurisdictionable_id", :valid_from,
      Arel.sql("ST_AsGeoJSON(ST_SimplifyPreserveTopology(jurisdiction_boundaries.geometry, #{tolerance}))")).map do |id, valid_from, geometry|
      record = by_id.fetch(id)
      { type: "Feature", id: "#{record.model_name.singular}-#{id}",
        properties: { name: record.name, url: record_path(record), state_code: state&.code || record.code, boundary_year: valid_from.year },
        geometry: JSON.parse(geometry) }
    end
  end
end
