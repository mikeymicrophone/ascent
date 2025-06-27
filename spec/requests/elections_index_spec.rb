require 'rails_helper'

RSpec.describe "Elections Index", type: :request do
  describe "GET /elections" do
    context "with no elections" do
      it "renders successfully with empty state" do
        get elections_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Elections")
      end
    end

    context "with elections and candidates" do
      let!(:country) { create(:country, name: "United States", code: "US") }
      let!(:state) { create(:state, name: "California", country: country) }
      let!(:city) { create(:city, name: "Los Angeles", state: state) }
      let!(:position) { create(:position, title: "Mayor") }
      let!(:office) { create(:office, position: position, jurisdiction: city) }
      let!(:year) { create(:year, year: 2024) }
      
      let!(:upcoming_election) { create(:election, :upcoming, office: office, year: year, election_date: 1.month.from_now) }
      let!(:active_election) { create(:election, :active, office: office, year: year, election_date: Date.current) }
      let!(:completed_election) { create(:election, :completed, office: office, year: year, election_date: 1.month.ago) }
      
      let!(:candidate1) { create(:person, :experienced_politician, first_name: "John", last_name: "Smith") }
      let!(:candidate2) { create(:person, :business_leader, first_name: "Jane", last_name: "Doe") }
      let!(:candidate3) { create(:person, :young_candidate, first_name: "Alex", last_name: "Johnson") }
      
      let!(:candidacy1) { create(:candidacy, election: active_election, person: candidate1, party_affiliation: "Democratic") }
      let!(:candidacy2) { create(:candidacy, election: active_election, person: candidate2, party_affiliation: "Republican") }
      let!(:candidacy3) { create(:candidacy, election: completed_election, person: candidate3, party_affiliation: "Independent") }

      it "renders successfully with election data" do
        get elections_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Elections")
      end

      it "displays different election statuses" do
        get elections_path
        
        expect(response.body).to include("upcoming").or include("Upcoming")
        expect(response.body).to include("active").or include("Active") 
        expect(response.body).to include("completed").or include("Completed")
      end

      it "displays candidate information" do
        get elections_path
        
        expect(response.body).to include("John Smith")
        expect(response.body).to include("Jane Doe")
        expect(response.body).to include("Alex Johnson")
      end

      it "displays office and position information" do
        get elections_path
        
        expect(response.body).to include("Mayor")
        expect(response.body).to include("Los Angeles")
      end

      it "displays party affiliations" do
        get elections_path
        
        expect(response.body).to include("Democratic")
        expect(response.body).to include("Republican")
        expect(response.body).to include("Independent")
      end

      it "includes proper HTML structure for complex Phlex components" do
        get elections_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with office filtering" do
      let!(:mayor_office) { create(:office, :city_level) }
      let!(:governor_office) { create(:office, :state_level) }
      let!(:mayor_election) { create(:election, office: mayor_office) }
      let!(:governor_election) { create(:election, office: governor_office) }

      it "renders successfully when filtering by office" do
        get elections_path, params: { office_id: mayor_office.id }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Elections")
      end

      it "handles invalid office_id parameter gracefully" do
        get elections_path, params: { office_id: 999999 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Elections")
      end
    end

    context "with large datasets" do
      before do
        # Create multiple elections with candidacies to test performance
        5.times do |i|
          office = create(:office)
          election = create(:election, office: office)
          3.times { create(:candidacy, election: election) }
        end
      end

      it "renders successfully with multiple elections and candidates" do
        get elections_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Elections")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        # Mock a database error
        allow(Election).to receive(:with_full_details).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get elections_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
  
  describe "GET /offices/:office_id/elections" do
    let!(:office) { create(:office, :city_level) }
    let!(:election) { create(:election, office: office) }
    
    it "renders elections scoped to specific office" do
      get office_elections_path(office)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Elections")
    end
    
    it "handles non-existent office gracefully" do
      expect { get office_elections_path(999999) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end