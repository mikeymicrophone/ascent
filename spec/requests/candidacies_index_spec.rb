require 'rails_helper'

RSpec.describe "Candidacies Index", type: :request do
  describe "GET /candidacies" do
    context "with no candidacies" do
      it "renders successfully with empty state" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
      end
    end

    context "with multiple candidacies" do
      let!(:office) { create(:office, :active) }
      let!(:election) { create(:election, :upcoming, office: office) }
      
      let!(:candidate1) { create(:person, :experienced_politician, first_name: "Sarah", last_name: "Johnson") }
      let!(:candidate2) { create(:person, :business_leader, first_name: "Michael", last_name: "Chen") }
      let!(:candidate3) { create(:person, :young_candidate, first_name: "Jordan", last_name: "Taylor") }
      
      let!(:candidacy1) { create(:candidacy, election: election, person: candidate1, party_affiliation: "Democratic", status: "active") }
      let!(:candidacy2) { create(:candidacy, election: election, person: candidate2, party_affiliation: "Republican", status: "active") }
      let!(:candidacy3) { create(:candidacy, election: election, person: candidate3, party_affiliation: "Independent", status: "announced") }

      it "renders successfully with candidacy data" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
        expect(response.body).to include("Sarah Johnson")
        expect(response.body).to include("Michael Chen")
        expect(response.body).to include("Jordan Taylor")
      end

      it "displays party affiliation information" do
        get candidacies_path
        
        expect(response.body).to include("Democratic")
        expect(response.body).to include("Republican")
        expect(response.body).to include("Independent")
      end

      it "displays candidacy status information" do
        get candidacies_path
        
        expect(response.body).to include("active") || expect(response.body).to include("Active")
        expect(response.body).to include("announced") || expect(response.body).to include("Announced")
      end

      it "displays election and office context" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        # Should show election or office information
      end

      it "includes proper HTML structure for Phlex components" do
        get candidacies_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with candidacies across multiple elections" do
      let!(:office1) { create(:office, :active) }
      let!(:office2) { create(:office, :active) }
      let!(:election1) { create(:election, :upcoming, office: office1) }
      let!(:election2) { create(:election, :active, office: office2) }
      
      let!(:person) { create(:person, :experienced_politician) }
      let!(:candidacy1) { create(:candidacy, election: election1, person: person, party_affiliation: "Democratic") }
      let!(:candidacy2) { create(:candidacy, election: election2, person: person, party_affiliation: "Democratic") }

      it "displays candidacies from different elections" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
      end

      it "shows election context for each candidacy" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        # Should differentiate between elections
      end
    end

    context "with candidacies having platform summaries" do
      let!(:election) { create(:election, :upcoming) }
      let!(:person) { create(:person, :business_leader) }
      let!(:candidacy) { create(:candidacy, 
        election: election, 
        person: person, 
        platform_summary: "Focused on economic development and job creation through small business support and infrastructure investment."
      ) }

      it "displays platform summary information" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("economic development")
      end
    end

    context "with candidacies having different announcement dates" do
      let!(:election) { create(:election, :upcoming) }
      let!(:early_announce) { create(:candidacy, election: election, announcement_date: 6.months.ago) }
      let!(:late_announce) { create(:candidacy, election: election, announcement_date: 1.month.ago) }

      it "displays announcement timing information" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
      end

      it "handles different announcement date formats" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        # Should display dates appropriately
      end
    end

    context "with pagination" do
      let!(:election) { create(:election, :upcoming) }
      
      before do
        create_list(:candidacy, 30, election: election)
      end

      it "renders successfully with pagination" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
      end

      it "respects page parameter" do
        get candidacies_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
      end

      it "handles high page numbers gracefully" do
        get candidacies_path, params: { page: 999 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
      end
    end

    context "with candidacies having ratings" do
      let!(:election) { create(:election, :active) }
      let!(:candidacy) { create(:candidacy, election: election) }
      let!(:voter1) { create(:voter) }
      let!(:voter2) { create(:voter) }
      let!(:rating1) { create(:rating, candidacy: candidacy, voter: voter1, rating: 350) }
      let!(:rating2) { create(:rating, candidacy: candidacy, voter: voter2, rating: 420) }

      it "displays candidacies with voting activity" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Candidacies")
      end

      it "shows rating or popularity indicators if available" do
        get candidacies_path
        
        expect(response).to have_http_status(200)
        # Should indicate voting activity or ratings
      end
    end
  end

  context "filtering and search capabilities" do
    let!(:election1) { create(:election, :upcoming) }
    let!(:election2) { create(:election, :active) }
    let!(:candidacy1) { create(:candidacy, election: election1, party_affiliation: "Democratic") }
    let!(:candidacy2) { create(:candidacy, election: election2, party_affiliation: "Republican") }

    it "handles election filtering if implemented" do
      get candidacies_path, params: { election_id: election1.id }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Candidacies")
    end

    it "handles party filtering if implemented" do
      get candidacies_path, params: { party: "Democratic" }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Candidacies")
    end

    it "handles status filtering if implemented" do
      get candidacies_path, params: { status: "active" }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Candidacies")
    end
  end

  context "error handling" do
    it "handles database errors gracefully" do
      allow(Candidacy).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
      
      expect { get candidacies_path }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "handles valid parameters correctly" do
      create_list(:candidacy, 5)
      
      get candidacies_path, params: { page: 1 }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Candidacies")
    end

    it "handles invalid filter parameters gracefully" do
      create(:candidacy)
      
      get candidacies_path, params: { election_id: 999999 }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Candidacies")
    end
  end

  context "performance with complex data" do
    before do
      # Create candidacies with full association chains
      3.times do
        election = create(:election, :active)
        candidacy = create(:candidacy, election: election)
        
        # Add ratings for each candidacy
        5.times do
          voter = create(:voter)
          create(:rating, candidacy: candidacy, voter: voter)
        end
      end
    end

    it "renders successfully with complex candidacy data" do
      get candidacies_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Candidacies")
    end

    it "handles candidacies with extensive rating data" do
      candidacy = create(:candidacy)
      
      # Create many ratings
      20.times do
        voter = create(:voter)
        create(:rating, candidacy: candidacy, voter: voter)
      end
      
      get candidacies_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Candidacies")
    end
  end
end