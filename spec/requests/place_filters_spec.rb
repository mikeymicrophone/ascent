require "rails_helper"

RSpec.describe "Place list filters", type: :request do
  let!(:country) { create(:country, name: "United States", code: "US") }
  let!(:new_york) { create(:state, :with_jurisdiction, name: "New York", code: "NY", country: country) }
  let!(:vermont) { create(:state, :with_jurisdiction, name: "Vermont", code: "VT", country: country) }
  let!(:albany_county) { create(:county, name: "Albany County", state: new_york) }
  let!(:schenectady_county) { create(:county, name: "Schenectady County", state: new_york) }
  let!(:washington_county) { create(:county, name: "Washington County", state: vermont) }
  let!(:albany) { create(:municipality, name: "Albany", state: new_york, county: albany_county) }
  let!(:colonie) { create(:municipality, name: "Colonie", state: new_york, county: albany_county) }
  let!(:schenectady) { create(:municipality, name: "Schenectady", state: new_york, county: schenectady_county) }
  let!(:montpelier) { create(:municipality, name: "Montpelier", state: vermont, county: washington_county) }
  let!(:senate_2) { district_for(new_york, "New York State Senate District 2", "state senate district") }
  let!(:senate_10) { district_for(new_york, "New York State Senate District 10", "state senate district") }
  let!(:assembly) { district_for(new_york, "New York Assembly District 1", "assembly district") }
  let!(:congress) { district_for(vermont, "Vermont At-Large Congressional District", "congressional district") }

  def district_for(state, name, kind)
    create(:district, name: name, kind: kind).tap { it.create_jurisdiction!(parent: state.jurisdiction) }
  end

  def page
    Nokogiri::HTML(response.body)
  end

  def titles(frame)
    page.css("##{frame} .list-row-title").map(&:text)
  end

  it "automatically submits dropdown changes on all three place lists" do
    { counties_path => %w[state_id], municipalities_path => %w[state_id county_id], districts_path => %w[state_id kind] }.each do |path, fields|
      get path
      expect(response).to have_http_status(:ok)
      form = page.at_css("form.filter-form")
      expect(form["data-controller"]).to eq("form-submit")
      expect(form.css("select").map { it["name"] }).to eq(fields)
      expect(form.css("select").map { it["data-action"] }).to all(eq("change->form-submit#submit"))
    end
  end

  it "combines county name search with state filtering" do
    get counties_path, params: { state_id: new_york.id, q: "albany" }

    expect(titles("counties-list")).to eq([ albany_county.name ])
    expect(page.at_css('select[name="state_id"] option[selected]')["value"]).to eq(new_york.id.to_s)
    expect(page.at_css('input[name="q"]')["value"]).to eq("albany")
    get page.at_css(".filter-actions a")["href"]
    expect(titles("counties-list").size).to eq(3)
  end

  it "limits municipality county choices to the active state" do
    get municipalities_path, params: { state_id: new_york.id }

    expect(titles("municipalities-list")).to eq([ albany.name, colonie.name, schenectady.name ])
    expect(page.css('select[name="county_id"] option').map(&:text)).to eq([
      "All counties", "Albany County · NY", "Schenectady County · NY"
    ])
  end

  it "keeps the state and county controls available when a county is selected" do
    get municipalities_path, params: { county_id: albany_county.id }

    expect(titles("municipalities-list")).to eq([ albany.name, colonie.name ])
    expect(response.body).to include("Cities and towns in Albany County")
    expect(page.at_css('select[name="state_id"]')).to be_present
    expect(page.at_css('select[name="county_id"] option[selected]')["value"]).to eq(albany_county.id.to_s)
    expect(page.css('input[type="hidden"][name="county_id"]')).to be_empty
    clear = page.at_css(".filter-actions a")["href"]
    expect(clear).to eq(municipalities_path)
    get clear
    expect(titles("municipalities-list").size).to eq(4)
  end

  it "clears an incompatible county when switching states" do
    get municipalities_path, params: { state_id: vermont.id, county_id: albany_county.id }

    expect(titles("municipalities-list")).to eq([ montpelier.name ])
    expect(page.css('select[name="county_id"] option').map(&:text)).to eq([ "All counties", "Washington County · VT" ])
    expect(page.css('select[name="county_id"] option[selected]').map { it["value"] }).not_to include(albany_county.id.to_s)
    expect(response.body).not_to include("Cities and towns in Albany County")
  end

  it "combines municipality name, state, and county filters" do
    get municipalities_path, params: { q: "col", state_id: new_york.id, county_id: albany_county.id }

    expect(titles("municipalities-list")).to eq([ colonie.name ])
    expect(page.at_css('select[name="state_id"] option[selected]')["value"]).to eq(new_york.id.to_s)
    expect(page.at_css('select[name="county_id"] option[selected]')["value"]).to eq(albany_county.id.to_s)
  end

  it "offers every county again when the state is cleared" do
    get municipalities_path, params: { state_id: "", county_id: albany_county.id }

    expect(titles("municipalities-list")).to eq([ albany.name, colonie.name ])
    expect(page.css('select[name="county_id"] option').map { it["value"] }).to contain_exactly(
      "", albany_county.id.to_s, schenectady_county.id.to_s, washington_county.id.to_s
    )
  end

  it "preserves municipality filters across pagination and resets the page on a new submission" do
    create_list(:municipality, 26, state: new_york, county: albany_county)
    get municipalities_path, params: { state_id: new_york.id, county_id: albany_county.id }

    next_link = page.at_css('a[rel="next"]')["href"]
    values = Rack::Utils.parse_nested_query(URI.parse(next_link).query)
    expect(values).to include("state_id" => new_york.id.to_s, "county_id" => albany_county.id.to_s, "page" => "2")
    get next_link
    expect(titles("municipalities-list").size).to eq(3)
    expect(page.at_css('select[name="county_id"] option[selected]')["value"]).to eq(albany_county.id.to_s)
    form = page.at_css("form.filter-form")
    expect(form["action"]).to eq(municipalities_path)
    expect(form.css('input[name="page"]')).to be_empty
  end

  it "limits district kinds to the active state independently of name search" do
    get districts_path, params: { state_id: new_york.id, q: "10" }

    expect(titles("districts-list")).to eq([ senate_10.name ])
    expect(page.css('select[name="kind"] option').map(&:text)).to eq([ "Every kind", "Assembly district", "State senate district" ])
  end

  it "combines district state and kind filters and keeps districts in natural order" do
    get districts_path, params: { state_id: new_york.id, kind: "state senate district" }

    expect(titles("districts-list")).to eq([ senate_2.name, senate_10.name ])
    expect(page.at_css('select[name="kind"] option[selected]')["value"]).to eq("state senate district")
    get page.at_css(".filter-actions a")["href"]
    expect(titles("districts-list").size).to eq(4)
  end

  it "clears a district kind that is unavailable in the new state" do
    get districts_path, params: { state_id: vermont.id, kind: "assembly district" }

    expect(titles("districts-list")).to eq([ congress.name ])
    expect(page.css('select[name="kind"] option').map(&:text)).to eq([ "Every kind", "Congressional district" ])
    expect(page.css('select[name="kind"] option[selected]').map { it["value"] }).not_to include("assembly district")
  end
end
