require "rails_helper"

RSpec.describe "Map explorer", type: :request do
  include ActiveSupport::Testing::TimeHelpers

  around { |example| travel_to(Time.zone.local(2026, 10, 31, 12)) { example.run } }
  let(:country) { create(:country, code: "US", name: "United States") }
  let(:state) { create(:state, :with_jurisdiction, code: "NY", name: "New York", country: country) }
  let(:county) { create(:county, :with_jurisdiction, state: state, name: "Kings County") }
  let(:other_state) { create(:state, :with_jurisdiction, code: "VT", name: "Vermont", country: country) }

  def boundary(jurisdiction, from: Date.new(2024, 1, 1), until_date: nil)
    shape = RGeo::Geos.factory(srid: 4326).parse_wkt(
      "MULTIPOLYGON(((-74 42,-73 42,-73 43,-74 43,-74 42),(-73.8 42.2,-73.8 42.4,-73.6 42.4,-73.6 42.2,-73.8 42.2)),((-72 42,-71 42,-71 43,-72 43,-72 42)))"
    )
    jurisdiction.boundaries.create!(geometry: shape, valid_from: from, valid_until: until_date)
  end

  def payload
    JSON.parse(response.body)
  end

  it "shows public state links and Alaska/Hawaii insets even before geometry is imported" do
    state
    get map_path

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css("h1").text).to eq("Explore the United States")
    expect(page.at_css(%(.map-place-links a[href="#{map_path(state_id: state.id)}"])).text).to eq(state.name)
    expect(page.css('[data-boundary-map-target="inset"]').map { it["data-state-code"] }).to eq(%w[AK HI])
    expect(page.at_css('form[aria-label="Choose map area"]')).to be_present
  end

  it "returns only US states, preserving multipart geometry and holes without changing the source" do
    original = boundary(state.jurisdiction)
    stored = original.geometry.as_text
    canada = create(:country, code: "CA", name: "Canada")
    province = create(:state, :with_jurisdiction, code: "ON", country: canada)
    boundary(province.jurisdiction)

    get features_map_path

    expect(response).to have_http_status(:ok)
    expect(payload["type"]).to eq("FeatureCollection")
    expect(payload["features"].size).to eq(1)
    feature = payload["features"].first
    expect(feature["properties"]).to include("name" => state.name, "url" => map_path(state_id: state.id), "boundary_year" => 2024)
    expect(feature["geometry"]["type"]).to eq("MultiPolygon")
    expect(feature["geometry"]["coordinates"].size).to eq(2)
    expect(feature["geometry"]["coordinates"].first.size).to eq(2)
    expect(original.reload.geometry.as_text).to eq(stored)
    expect(payload["vintages"]).to eq([ 2024 ])
    expect(payload["outline"]).to be_nil
  end

  it "loads counties only for the selected state, with a separate state outline" do
    boundary(state.jurisdiction)
    boundary(county.jurisdiction)
    elsewhere = create(:county, :with_jurisdiction, state: other_state)
    boundary(elsewhere.jurisdiction)

    get features_map_path(state_id: state.id, layer: "counties")

    expect(payload["features"].map { it["properties"]["name"] }).to eq([ county.name ])
    expect(payload["features"].first["properties"]["url"]).to eq(county_path(county))
    expect(payload["outline"]["properties"]["name"]).to eq(state.name)
  end

  it "selects each legislative chamber independently and links districts to their own pages" do
    kinds = { "congressional" => "congressional district", "state_senate" => "state senate district", "state_house" => "assembly district" }
    districts = kinds.to_h do |layer, kind|
      district = create(:district, name: "New York #{kind} 10", kind: kind)
      jurisdiction = create(:jurisdiction, jurisdictionable: district, parent: state.jurisdiction)
      boundary(jurisdiction)
      [ layer, district ]
    end
    elsewhere = create(:district, kind: "congressional district")
    boundary(create(:jurisdiction, jurisdictionable: elsewhere, parent: other_state.jurisdiction))

    districts.each do |layer, district|
      get features_map_path(state_id: state.id, layer: layer)

      expect(response).to have_http_status(:ok)
      expect(payload["features"].map { it["properties"]["url"] }).to eq([ district_path(district) ])
    end
  end

  it "uses the effective boundary and excludes future geometry" do
    boundary(state.jurisdiction, from: Date.new(2020, 1, 1), until_date: Date.new(2026, 1, 1))
    boundary(state.jurisdiction, from: Date.new(2026, 1, 1), until_date: Date.new(2030, 1, 1))
    boundary(state.jurisdiction, from: Date.new(2030, 1, 1))

    get features_map_path

    expect(payload["features"].size).to eq(1)
    expect(payload["vintages"]).to eq([ 2026 ])
  end

  it "keeps place links available with missing geometry and shows empty layers clearly" do
    county
    get map_path(state_id: state.id)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css(%(.map-place-links a[href="#{county_path(county)}"]))).to be_present
    expect(page.at_css('a[href="/map"]')).to be_present
    expect(page.at_css('select[name="layer"] option[selected]')["value"]).to eq("counties")

    get features_map_path(state_id: state.id)
    expect(payload).to include("features" => [], "outline" => nil, "vintages" => [])

    get map_path(state_id: state.id, layer: "state_senate")
    expect(response.body).to include("No state senate districts are recorded here yet.")
  end

  it "rejects unknown states, non-US states, and unknown layers" do
    canada = create(:country, code: "CA")
    province = create(:state, country: canada)
    [ { state_id: 0 }, { state_id: province.id }, { layer: "municipalities" } ].each do |parameters|
      get map_path, params: parameters
      expect(response).to have_http_status(:not_found)
      get features_map_path, params: parameters
      expect(response).to have_http_status(:not_found)
    end
  end

  it "returns only public map metadata without voter or residence data" do
    boundary(state.jurisdiction)
    create(:voter)

    get features_map_path

    expect(payload["features"].first["properties"].keys).to match_array(%w[name url state_code boundary_year])
    expect(response.body).not_to include("email", "voter_id", "residence", "latitude", "longitude")
  end

  it "rejects a state array instead of treating it as a multi-state selection" do
    get features_map_path, params: { state_id: [ state.id, other_state.id ] }

    expect(response).to have_http_status(:bad_request)
  end
end
