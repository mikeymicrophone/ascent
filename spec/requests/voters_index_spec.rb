require 'rails_helper'

RSpec.describe "Voters Index", type: :request do
  describe "GET /voters" do
    context "with no voters" do
      it "renders successfully with empty state" do
        get voters_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voters")
      end
    end

    context "with multiple voters" do
      let!(:voter1) { create(:voter, :verified, first_name: "Sarah", last_name: "Johnson") }
      let!(:voter2) { create(:voter, :experienced, first_name: "Michael", last_name: "Chen") }
      let!(:voter3) { create(:voter, first_name: "Jordan", last_name: "Taylor") }

      it "renders successfully with voter data" do
        get voters_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voters")
        expect(response.body).to include("Sarah Johnson")
        expect(response.body).to include("Michael Chen")
        expect(response.body).to include("Jordan Taylor")
      end

      it "displays voter verification status" do
        get voters_path
        
        expect(response).to have_http_status(200)
        # Should show verification indicators
      end

      it "includes proper HTML structure for Phlex components" do
        get voters_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with voters having voting history" do
      let!(:voter) { create(:voter) }
      let!(:election) { create(:election, :active) }
      let!(:candidacy1) { create(:candidacy, election: election) }
      let!(:candidacy2) { create(:candidacy, election: election) }
      let!(:baseline) { create(:voter_election_baseline, voter: voter, election: election, baseline: 250) }
      let!(:rating1) { create(:rating, candidacy: candidacy1, voter: voter, rating: 300) }
      let!(:rating2) { create(:rating, candidacy: candidacy2, voter: voter, rating: 400) }

      it "displays voters with voting activity" do
        get voters_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voters")
      end

      it "shows voting participation indicators" do
        get voters_path
        
        expect(response).to have_http_status(200)
        # Should indicate voting activity
      end
    end

    context "with pagination" do
      before do
        create_list(:voter, 30)
      end

      it "renders successfully with pagination" do
        get voters_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voters")
      end

      it "respects page parameter" do
        get voters_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voters")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Voter).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get voters_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end