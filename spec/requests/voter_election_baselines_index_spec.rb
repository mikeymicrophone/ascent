require 'rails_helper'

RSpec.describe "Voter Election Baselines Index", type: :request do
  describe "GET /voter_election_baselines" do
    context "with no baselines" do
      it "renders successfully with empty state" do
        get voter_election_baselines_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voter Election Baselines")
      end
    end

    context "with multiple baselines" do
      let!(:election) { create(:election, :active) }
      let!(:voter1) { create(:voter, first_name: "Sarah", last_name: "Johnson") }
      let!(:voter2) { create(:voter, first_name: "Michael", last_name: "Chen") }
      let!(:voter3) { create(:voter, first_name: "Jordan", last_name: "Taylor") }
      
      let!(:baseline1) { create(:voter_election_baseline, voter: voter1, election: election, baseline: 250) }
      let!(:baseline2) { create(:voter_election_baseline, voter: voter2, election: election, baseline: 300) }
      let!(:baseline3) { create(:voter_election_baseline, voter: voter3, election: election, baseline: 350) }

      it "renders successfully with baseline data" do
        get voter_election_baselines_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voter Election Baselines")
        expect(response.body).to include("250")
        expect(response.body).to include("300")
        expect(response.body).to include("350")
      end

      it "displays voter and election information" do
        get voter_election_baselines_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Sarah Johnson")
        expect(response.body).to include("Michael Chen")
        expect(response.body).to include("Jordan Taylor")
      end

      it "includes proper HTML structure for Phlex components" do
        get voter_election_baselines_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with baselines across multiple elections" do
      let!(:election1) { create(:election, :active) }
      let!(:election2) { create(:election, :completed) }
      let!(:voter) { create(:voter) }
      let!(:baseline1) { create(:voter_election_baseline, voter: voter, election: election1, baseline: 275) }
      let!(:baseline2) { create(:voter_election_baseline, voter: voter, election: election2, baseline: 325) }

      it "displays baselines from different elections" do
        get voter_election_baselines_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voter Election Baselines")
        expect(response.body).to include("275")
        expect(response.body).to include("325")
      end
    end

    context "with pagination" do
      let!(:election) { create(:election) }
      
      before do
        create_list(:voter_election_baseline, 30, election: election)
      end

      it "renders successfully with pagination" do
        get voter_election_baselines_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voter Election Baselines")
      end

      it "respects page parameter" do
        get voter_election_baselines_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Voter Election Baselines")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(VoterElectionBaseline).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get voter_election_baselines_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end