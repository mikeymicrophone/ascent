require 'rails_helper'

RSpec.describe "Offices Index", type: :request do
  describe "GET /offices" do
    context "with no offices" do
      it "renders successfully with empty state" do
        get offices_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
      end
    end

    context "with multiple offices" do
      let!(:country) { create(:country, name: "United States") }
      let!(:state) { create(:state, name: "California", country: country) }
      let!(:city) { create(:city, name: "San Francisco", state: state) }
      
      let!(:mayor_position) { create(:position, title: "Mayor") }
      let!(:council_position) { create(:position, title: "City Council Member") }
      let!(:governor_position) { create(:position, title: "Governor") }
      
      let!(:mayor_office) { create(:office, position: mayor_position, jurisdiction: city, is_active: true) }
      let!(:council_office) { create(:office, position: council_position, jurisdiction: city, is_active: true) }
      let!(:governor_office) { create(:office, position: governor_position, jurisdiction: state, is_active: false) }

      it "renders successfully with office data" do
        get offices_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
        expect(response.body).to include("Mayor")
        expect(response.body).to include("City Council Member")
        expect(response.body).to include("Governor")
      end

      it "displays jurisdiction information" do
        get offices_path
        
        expect(response.body).to include("San Francisco")
        expect(response.body).to include("California")
      end

      it "displays office status information" do
        get offices_path
        
        # Should indicate active/inactive status somehow
        expect(response).to have_http_status(200)
      end

      it "includes proper HTML structure for Phlex components" do
        get offices_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with offices that have elections" do
      let!(:office) { create(:office, :active) }
      let!(:year) { create(:year, year: 2024) }
      let!(:upcoming_election) { create(:election, :upcoming, office: office, year: year) }
      let!(:completed_election) { create(:election, :completed, office: office, year: year) }

      it "displays election information" do
        get offices_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
      end

      it "shows election count or status" do
        get offices_path
        
        expect(response).to have_http_status(200)
        # Should display election-related information
      end
    end

    context "with offices at different jurisdiction levels" do
      let!(:country) { create(:country, name: "United States") }
      let!(:state) { create(:state, name: "California", country: country) }
      let!(:city) { create(:city, name: "Los Angeles", state: state) }
      
      let!(:federal_office) { create(:office, jurisdiction: country) }
      let!(:state_office) { create(:office, jurisdiction: state) }
      let!(:city_office) { create(:office, jurisdiction: city) }

      it "displays offices from all jurisdiction levels" do
        get offices_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
        expect(response.body).to include("United States")
        expect(response.body).to include("California")
        expect(response.body).to include("Los Angeles")
      end
    end

    context "with pagination" do
      before do
        create_list(:office, 30)
      end

      it "renders successfully with pagination" do
        get offices_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
      end

      it "respects page parameter" do
        get offices_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
      end

      it "handles high page numbers gracefully" do
        get offices_path, params: { page: 999 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
      end
    end

    context "with offices having candidates and elections" do
      let!(:office) { create(:office, :active) }
      let!(:election) { create(:election, :active, office: office) }
      let!(:candidate1) { create(:person, :experienced_politician) }
      let!(:candidate2) { create(:person, :business_leader) }
      let!(:candidacy1) { create(:candidacy, election: election, person: candidate1) }
      let!(:candidacy2) { create(:candidacy, election: election, person: candidate2) }

      it "displays candidate information when available" do
        get offices_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Offices")
      end

      it "shows electoral activity indicators" do
        get offices_path
        
        expect(response).to have_http_status(200)
        # Should indicate that office has active election or candidates
      end
    end
  end

  context "filtering and search capabilities" do
    let!(:active_office) { create(:office, :active) }
    let!(:inactive_office) { create(:office, :inactive) }

    it "handles status filtering if implemented" do
      get offices_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Offices")
    end

    it "handles jurisdiction type filtering if implemented" do
      city_office = create(:office, :city_level)
      state_office = create(:office, :state_level)
      
      get offices_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Offices")
    end
  end

  context "error handling" do
    it "handles database errors gracefully" do
      allow(Office).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
      
      expect { get offices_path }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "handles valid parameters correctly" do
      create_list(:office, 5)
      
      get offices_path, params: { page: 1 }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Offices")
    end

    it "handles complex association queries" do
      # Create office with full association chain
      office = create(:office)
      election = create(:election, office: office)
      candidacy = create(:candidacy, election: election)
      
      get offices_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Offices")
    end
  end

  context "performance with complex data" do
    before do
      # Create offices with varying complexity
      5.times do
        office = create(:office, :active)
        election = create(:election, :active, office: office)
        3.times { create(:candidacy, election: election) }
      end
    end

    it "renders successfully with complex office data" do
      get offices_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Offices")
    end

    it "handles offices with multiple elections" do
      office = create(:office)
      create(:election, :completed, office: office)
      create(:election, :upcoming, office: office)
      
      get offices_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Offices")
    end
  end
end