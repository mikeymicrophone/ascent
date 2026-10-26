require "rails_helper"

# TIGER/Line boundaries arrive as shapefiles or GeoJSON. The importer matches each feature to a
# jurisdiction we already have (by census ID once recorded, else by name within its state), creates any
# congressional or legislative district the seed data lacks, stores its shape as a dated boundary, and
# leaves anything it cannot place in a report. The shapes here are simple squares.
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

  it "lets a voter's location find their town and districts once boundaries are in" do
    alder_county.jurisdiction.update!(parent: vermont.jurisdiction)
    port_merritt.jurisdiction.update!(parent: alder_county.jurisdiction)
    import
    claim = ResidenceClaim.new(latitude: 43.7, longitude: -72.3, voter: create(:voter))

    expect(claim.town).to eq(port_merritt.jurisdiction)
    expect(claim.districts.values).to contain_exactly(at_large.jurisdiction, house_12a.jurisdiction, nil)
    expect(claim.ballot_jurisdictions.map(&:name)).to include("Alder County", "Vermont")
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

  describe "legislative districts" do
    let!(:middlesex_35) { create(:district, :with_jurisdiction, name: "Vermont State House District: Thirty-Fifth Middlesex", kind: "state house district") }

    def import_districts(*features)
      described_class.new(vintage: 2025).import_all([ collection_file("tl_2025_50_sldl.geojson", features) ])
    end

    it "matches a district however its name is spelled" do
      report = import_districts(feature({ "MTFCC" => "G5220", "GEOID" => "50M35", "SLDLST" => "M35", "NAMELSAD" => "35th Middlesex District" }, square(-72, 44)))

      expect(report).to include(matched: 1, created: 0)
      expect(middlesex_35.jurisdiction.reload).to have_attributes(census_geoid: "50M35", parent: vermont.jurisdiction)
    end

    it "creates a district the seed data lacks, under its state, and skips areas outside every district" do
      report = import_districts(
        feature({ "MTFCC" => "G5210", "GEOID" => "50BEN", "STATEFP" => "50", "SLDUST" => "BEN", "NAMELSAD" => "Bennington Senatorial District" }, square(-73, 42.7)),
        feature({ "MTFCC" => "G5220", "GEOID" => "50C13", "STATEFP" => "50", "SLDLST" => "C13", "NAMELSAD" => "Chittenden-13 State House District" }, square(-73, 44.4)),
        feature({ "MTFCC" => "G5220", "GEOID" => "50ZZZ", "STATEFP" => "50", "SLDLST" => "ZZZ", "NAMELSAD" => "State House Districts not defined" }, square(-71, 44)))

      expect(report).to include(created: 2, skipped: 1, unmatched_count: 0)
      bennington = District.find_by!(name: "Vermont State Senate District Bennington")
      expect(bennington).to have_attributes(kind: "state senate district", chamber: "state_senate")
      expect(bennington.jurisdiction).to have_attributes(parent: vermont.jurisdiction, census_geoid: "50BEN")
      expect(District.find_by!(name: "Vermont State House District Chittenden-13").jurisdiction.boundaries.count).to eq(1)
    end
  end

  it "tells a town from a same-named city by its seed code, and never lets one take the other's shape" do
    barre_city = create(:municipality, :with_jurisdiction, name: "Barre", entity_code: "MUNICIPALITY-USA-VT-BARRE_CITY", state: vermont, county: alder_county)
    barre_town = create(:municipality, :with_jurisdiction, name: "Barre", entity_code: "MUNICIPALITY-USA-VT-BARRE_TOWN", state: vermont, county: alder_county)
    file = collection_file("tl_2025_50_cousub.geojson", [
      feature({ "MTFCC" => "G4040", "GEOID" => "5002303175", "COUSUBFP" => "03175", "NAME" => "Barre", "NAMELSAD" => "Barre city" }, square(-72.5, 44.2, 0.1)),
      feature({ "MTFCC" => "G4040", "GEOID" => "5002303250", "COUSUBFP" => "03250", "NAME" => "Barre", "NAMELSAD" => "Barre town" }, square(-72.6, 44.1, 0.3)),
      feature({ "MTFCC" => "G4040", "GEOID" => "5002300000", "COUSUBFP" => "00000", "NAME" => "County subdivisions not defined" }, square(-71, 44))
    ])
    place = collection_file("tl_2025_50_place.geojson", [ feature({ "MTFCC" => "G4110", "GEOID" => "5003175", "NAME" => "Barre", "NAMELSAD" => "Barre city" }, square(-72.5, 44.2, 0.1)) ])

    report = described_class.new(vintage: 2025).import_all([ file, place ])

    expect(report).to include(matched: 2, skipped: 1, placed_elsewhere: 1, ambiguous_count: 0)
    expect(barre_city.jurisdiction.reload.census_geoid).to eq("5002303175")
    expect(barre_town.jurisdiction.reload.census_geoid).to eq("5002303250")
  end

  it "reads a shapefile, reprojecting it to WGS 84", skip: (system("which ogr2ogr > /dev/null") ? false : "needs GDAL's ogr2ogr") do
    source = collection_file("county.geojson", [ county_feature ])
    shapefile = directory.join("tl_2025_us_county.shp")
    system("ogr2ogr", "-f", "ESRI Shapefile", "-a_srs", "EPSG:4269", shapefile.to_s, source.to_s, exception: true)

    expect(described_class.new(vintage: 2025).import(shapefile)).to include(written: 1)
    expect(alder_county.jurisdiction.boundaries.sole.geometry.envelope.exterior_ring.points.map(&:x).minmax.map { it.round(3) }).to eq([ -73.0, -71.0 ])
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
