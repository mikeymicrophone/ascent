require "rails_helper"

# TIGER/Line boundaries arrive as GeoJSON. The importer matches each feature to a jurisdiction we
# already have (by census ID once recorded, else by name within its state), stores its shape as a dated
# boundary, and leaves anything it cannot place in a report. The shapes here are simple squares.
RSpec.describe Seeds::TigerBoundaryImporter do
  let(:united_states) { create(:country, name: "United States", code: "US") }
  let(:vermont) { create(:state, :with_jurisdiction, name: "Vermont", code: "VT", country: united_states) }
  let(:alder_county) { create(:county, :with_jurisdiction, name: "Alder County", state: vermont) }
  let(:port_merritt) { create(:municipality, :with_jurisdiction, name: "Port Merritt", state: vermont, county: alder_county) }
  let(:at_large) { create(:district, :with_jurisdiction, name: "Vermont At-Large Congressional District", kind: "congressional district") }
  let(:senate_3) { create(:district, :with_jurisdiction, name: "Vermont State Senate District 3", kind: "state senate district") }
  let(:house_12a) { create(:district, :with_jurisdiction, name: "Vermont State House District 12A", kind: "state house district") }
  let(:directory) { Pathname(Dir.mktmpdir) }

  before { [ port_merritt, at_large, senate_3, house_12a ] }
  after { FileUtils.remove_entry(directory) }

  def square(west, south, size = 1.0)
    [ [ [ west, south ], [ west + size, south ], [ west + size, south + size ], [ west, south + size ], [ west, south ] ] ]
  end

  def feature(properties, rings, type: "MultiPolygon")
    { "type" => "Feature", "properties" => properties, "geometry" => { "type" => type, "coordinates" => type == "Polygon" ? rings : [ rings ] } }
  end

  def collection_file(name, features)
    directory.join(name).tap { it.write({ "type" => "FeatureCollection", "features" => features }.to_json) }
  end

  let(:county_feature) { feature({ "MTFCC" => "G4020", "GEOID" => "50001", "STATEFP" => "50", "NAME" => "Alder", "NAMELSAD" => "Alder County" }, square(-73, 43, 2)) }
  let(:place_feature) { feature({ "MTFCC" => "G4110", "GEOID" => "5057000", "STATEFP" => "50", "NAME" => "Port Merritt" }, square(-72.5, 43.5, 0.5), type: "Polygon") }
  let(:district_features) do
    [
      feature({ "MTFCC" => "G5200", "GEOID" => "5000", "STATEFP" => "50", "CD119FP" => "00" }, square(-74, 42, 4)),
      feature({ "MTFCC" => "G5210", "GEOID" => "50003", "STATEFP" => "50", "SLDUST" => "003" }, square(-74, 42, 0.5)),
      feature({ "MTFCC" => "G5220", "GEOID" => "5012A", "STATEFP" => "50", "SLDLST" => "12A" }, square(-72.6, 43.4, 0.8))
    ]
  end
  let(:unknown_place) { feature({ "mtfcc" => "G4110", "geoid" => "5099999", "statefp" => "50", "name" => "Halden Bay" }, square(-71, 44)) }
  let(:water) { feature({ "MTFCC" => "H2030", "GEOID" => "1", "STATEFP" => "50", "NAME" => "Lake" }, square(-71, 44)) }

  def import(vintage: 2025, dry_run: false)
    files = [ collection_file("tl_2025_50_place.geojson", [ place_feature, unknown_place, water ]),
              collection_file("tl_2025_us_county.geojson", [ county_feature ]),
              collection_file("tl_2025_50_districts.geojson", district_features) ]
    described_class.new(vintage: vintage, dry_run: dry_run).import_all(files)
  end

  it "matches features by name within their state, records census IDs, and stores MultiPolygon boundaries" do
    report = import

    expect(report).to include(matched: 5, written: 5, unmatched_count: 1, skipped: 1)
    expect(report[:unmatched]).to eq([ "G4110 5099999 Halden Bay (VT)" ])
    expect(port_merritt.jurisdiction.reload).to have_attributes(census_class: "G4110", census_geoid: "5057000")
    expect(house_12a.jurisdiction.boundaries.sole.geometry.geometry_type).to eq(RGeo::Feature::MultiPolygon)
    expect(alder_county.jurisdiction.boundaries.sole.valid_from).to eq(Date.new(2025, 1, 1))
  end

  it "lets a residence find its districts from a point once boundaries are in" do
    import
    residence = create(:residence, jurisdiction: port_merritt.jurisdiction,
      location: RGeo::Geos.factory(srid: 4326).point(-72.3, 43.7))

    expect(residence.ballot_jurisdictions.map(&:name)).to include(
      "Vermont At-Large Congressional District", "Vermont State House District 12A", "Alder County"
    )
    expect(residence.ballot_jurisdictions.map(&:name)).not_to include("Vermont State Senate District 3")
  end

  it "replaces the same vintage, closes the older boundary for a newer one, and then matches by census ID" do
    import
    port_merritt.update!(name: "Port Merritt City")

    import
    expect(port_merritt.jurisdiction.boundaries.count).to eq(1)

    import(vintage: 2026)
    boundaries = port_merritt.jurisdiction.boundaries.order(:valid_from)
    expect(boundaries.map { [ it.valid_from.year, it.valid_until&.year ] }).to eq([ [ 2025, 2026 ], [ 2026, nil ] ])
  end

  it "only reports matches in a dry run" do
    report = import(dry_run: true)

    expect(report).to include(matched: 5, written: 0)
    expect(JurisdictionBoundary.count).to eq(0)
    expect(port_merritt.jurisdiction.reload.census_geoid).to be_nil
  end

  it "reads newline-delimited and gzipped GeoJSON, repairing a self-crossing shape" do
    bowtie = [ [ [ -73, 43 ], [ -71, 45 ], [ -71, 43 ], [ -73, 45 ], [ -73, 43 ] ] ]
    path = directory.join("tl_2025_us_county.geojsonl.gz")
    Zlib::GzipWriter.open(path) { it.write("\u001E#{feature(county_feature["properties"], bowtie).to_json}\n\n") }

    report = described_class.new(vintage: 2025).import(path)

    expect(report).to include(written: 1, invalid_count: 0)
    expect(alder_county.jurisdiction.boundaries.sole.geometry).to be_valid
  end
end
