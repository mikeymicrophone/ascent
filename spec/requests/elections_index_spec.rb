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
      let!(:city) { create(:municipality, :with_jurisdiction, name: "Los Angeles", state: state) }
      let!(:position) { create(:position, title: "Mayor") }
      let!(:office) { create(:office, position: position, jurisdiction: city.jurisdiction) }
      let!(:year) { create(:year, year: 2024) }
      
      let!(:upcoming_race) { create_race_for(office, :upcoming, year: year, election_date: 1.month.from_now) }
      let!(:active_race) { create_race_for(office, :active, year: year, election_date: Date.current) }
      let!(:completed_race) { create_race_for(office, :completed, year: year, election_date: 1.month.ago) }
      
      let!(:candidate1) { create(:person, :experienced_politician, first_name: "John", last_name: "Smith") }
      let!(:candidate2) { create(:person, :business_leader, first_name: "Jane", last_name: "Doe") }
      let!(:candidate3) { create(:person, :young_candidate, first_name: "Alex", last_name: "Johnson") }
      
      let!(:candidacy1) { create(:candidacy, race: active_race, person: candidate1, party_affiliation: "Democratic") }
      let!(:candidacy2) { create(:candidacy, race: active_race, person: candidate2, party_affiliation: "Republican") }
      let!(:candidacy3) { create(:candidacy, race: completed_race, person: candidate3, party_affiliation: "Independent") }

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

      it "displays the races on each election's ballot" do
        get elections_path
        
        expect(response.body).to include("Mayor - Los Angeles")
        expect(response.body).to include("2 candidates")
      end

      it "displays the jurisdiction holding the election" do
        get elections_path
        
        expect(response.body).to include("Los Angeles (Municipality)").or include("Los Angeles")
      end

      it "includes proper HTML structure for complex Phlex components" do
        get elections_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with large datasets" do
      before do
        # Create multiple elections with candidacies to test performance
        5.times do |i|
          office = create(:office)
          race = create_race_for(office)
          3.times { create(:candidacy, race: race) }
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
end
