require "rails_helper"

# Every place's page shows the races it decides, counts the races decided by the places within it, and
# leads down to those places, with a breadcrumb up the jurisdiction tree.
RSpec.describe "Place pages", type: :request do
  include_context "Port Merritt ballot"

  let(:calder) { state.jurisdictionable }
  let(:alder) { alder_county.jurisdictionable }
  let!(:governor) { create_race_for(office_in(state, "Governor"), :active, name: "Calder General Election") }
  let!(:sheriff) { create_race_for(office_in(alder_county, "Sheriff"), :active) }
  let!(:mayor) { create_race_for(office_in(port_merritt, "Mayor"), :active) }
  let!(:assembly) { create_race_for(office_in(assembly_52, "Member of the Assembly"), :active) }

  describe "a state" do
    it "leads with its statewide races and counts those decided within it" do
      get state_path(calder)

      page = Nokogiri::HTML(response.body)
      expect(response).to have_http_status(:ok)
      expect(page.css(".breadcrumb a").map(&:text)).to eq([ "United States" ])
      expect(page.css("#place-ballot .place-race-office").map(&:text)).to eq([ "Governor" ])
      expect(page.css(".races-above-count").map(&:text)).to eq([ "1 county race", "1 city and town race", "1 district race" ])
      expect(response.body).to include("1 statewide race is open on the Calder General Election.")
    end

    it "leads down to its counties, a town search, and its districts by kind" do
      get state_path(calder)

      page = Nokogiri::HTML(response.body)
      expect(page.css(".place-chip-link").map(&:text)).to eq([ "Alder County" ])
      expect(page.at_css(%(form[action="#{municipalities_path}"] input[name="state_id"]))["value"]).to eq(calder.id.to_s)
      expect(page.at_css(%(a[href="#{districts_path(state_id: calder.id, kind: "assembly district")}"])).text).to eq("Assembly districts")
    end
  end

  describe "a county" do
    it "places itself in its state, leads with its own races, and lists its towns" do
      get county_path(alder)

      page = Nokogiri::HTML(response.body)
      expect(page.css(".breadcrumb a").map(&:text)).to eq([ "United States", "Calder" ])
      expect(page.css("#place-ballot .place-race-office").map(&:text)).to eq([ "Sheriff" ])
      expect(page.css(".place-chip-link").map(&:text)).to eq([ "Port Merritt" ])
      expect(page.css(".races-above-count").map(&:text)).to eq([ "1 city and town race" ])
    end
  end

  describe "a district" do
    it "names its kind and state, leads with its race, and lists the other districts of its kind" do
      create(:jurisdiction, parent: state, jurisdictionable: create(:district, name: "Assembly District 51", kind: "assembly district"))

      get district_path(assembly_52.jurisdictionable)

      page = Nokogiri::HTML(response.body)
      expect(page.css(".breadcrumb a").map(&:text)).to eq([ "United States", "Calder" ])
      expect(page.at_css(".eyebrow").text).to eq("Assembly district · Calder")
      expect(page.css("#place-ballot .place-race-office").map(&:text)).to eq([ "Member of the Assembly" ])
      expect(page.css(".nearby-list a").map(&:text)).to eq([ "Assembly District 51" ])
    end
  end

  describe "a country" do
    it "lists its states and counts the races decided within it" do
      get country_path(united_states.jurisdictionable)

      page = Nokogiri::HTML(response.body)
      expect(page.css(".place-chip-link").map(&:text)).to eq([ "Calder" ])
      expect(page.css(".races-above-count").map(&:text)).to include("1 state race")
      expect(page.at_css(".place-aside")).to be_nil
    end
  end

  describe "the lists" do
    it "finds counties and towns by name and narrows them by state or county" do
      elsewhere = create(:county, name: "Alder Creek County")

      get counties_path, params: { q: "alder", state_id: calder.id }

      expect(response.body).to include(%(id="list_item_county_#{alder.id}"))
      expect(response.body).not_to include(%(id="list_item_county_#{elsewhere.id}"))

      get municipalities_path, params: { county_id: alder.id }

      expect(response.body).to include("Cities and towns in Alder County", %(id="list_item_municipality_#{port_merritt.jurisdictionable.id}"))
    end

    it "orders districts by number and narrows them to a state's districts of one kind" do
      [ 10, 2 ].each { create(:jurisdiction, parent: state, jurisdictionable: create(:district, name: "Assembly District #{it}", kind: "assembly district")) }

      get districts_path, params: { state_id: calder.id, kind: "assembly district" }

      page = Nokogiri::HTML(response.body)
      expect(page.css(".list-row-title").map(&:text)).to eq([ "Assembly District 2", "Assembly District 10", "Assembly District 52" ])
    end
  end
end
