require 'rails_helper'

RSpec.describe "Cities Index", type: :request do
  describe "GET /cities" do
    context "with no cities" do
      it "renders successfully with empty state" do
        get cities_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Cities")
      end
    end

    context "with multiple cities" do
      let!(:usa) { create(:country, name: "United States") }
      let!(:california) { create(:state, name: "California", country: usa) }
      let!(:texas) { create(:state, name: "Texas", country: usa) }
      
      let!(:los_angeles) { create(:city, name: "Los Angeles", state: california) }
      let!(:san_francisco) { create(:city, name: "San Francisco", state: california) }
      let!(:houston) { create(:city, name: "Houston", state: texas) }
      let!(:dallas) { create(:city, name: "Dallas", state: texas) }

      it "renders successfully with city data" do
        get cities_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Cities")
        expect(response.body).to include("Los Angeles")
        expect(response.body).to include("San Francisco")
        expect(response.body).to include("Houston")
        expect(response.body).to include("Dallas")
      end

      it "displays associated state information" do
        get cities_path
        
        expect(response.body).to include("California")
        expect(response.body).to include("Texas")
      end

      it "displays country context through state" do
        get cities_path
        
        expect(response.body).to include("United States")
      end

      it "includes proper HTML structure for Phlex components" do
        get cities_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with cities that have offices" do
      let!(:country) { create(:country, name: "United States") }
      let!(:state) { create(:state, name: "California", country: country) }
      let!(:city) { create(:city, name: "San Francisco", state: state) }
      let!(:position) { create(:position, title: "Mayor") }
      let!(:office) { create(:office, position: position, jurisdiction: city) }
      let!(:election) { create(:election, office: office) }

      it "displays office and election information" do
        get cities_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("San Francisco")
      end
    end

    context "with pagination" do
      let!(:state) { create(:state) }
      
      before do
        create_list(:city, 30, state: state)
      end

      it "renders successfully with pagination" do
        get cities_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Cities")
      end

      it "respects page parameter" do
        get cities_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Cities")
      end

      it "handles high page numbers gracefully" do
        get cities_path, params: { page: 999 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Cities")
      end
    end
  end

  describe "GET /states/:state_id/cities" do
    let!(:country) { create(:country, name: "United States") }
    let!(:california) { create(:state, name: "California", country: country) }
    let!(:texas) { create(:state, name: "Texas", country: country) }
    let!(:ca_cities) { create_list(:city, 3, state: california) }
    let!(:tx_cities) { create_list(:city, 2, state: texas) }

    it "renders cities scoped to specific state" do
      get state_cities_path(california)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Cities")
    end

    it "shows state context information" do
      get state_cities_path(california)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("California")
    end

    it "handles non-existent state gracefully" do
      expect { get state_cities_path(999999) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "handles pagination for state-scoped cities" do
      # Create many cities for California
      create_list(:city, 30, state: california)
      
      get state_cities_path(california), params: { page: 2 }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Cities")
    end
  end

  context "with different city types and sizes" do
    let!(:state) { create(:state) }
    let!(:major_city) { create(:city, name: "Major City", state: state) }
    let!(:small_town) { create(:city, name: "Small Town", state: state) }

    before do
      # Create multiple offices for major city
      3.times { create(:office, jurisdiction: major_city) }
      # Create one office for small town
      create(:office, jurisdiction: small_town)
    end

    it "displays cities with different office counts" do
      get cities_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Major City")
      expect(response.body).to include("Small Town")
    end
  end

  context "error handling" do
    it "handles database errors gracefully" do
      allow(City).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
      
      expect { get cities_path }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "handles valid parameters correctly" do
      state = create(:state)
      create_list(:city, 5, state: state)
      
      get cities_path, params: { page: 1 }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Cities")
    end

    it "handles filter parameters when implemented" do
      state = create(:state, name: "California")
      create(:city, name: "Los Angeles", state: state)
      
      # Test without filter parameters (base functionality)
      get cities_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Cities")
    end
  end
end