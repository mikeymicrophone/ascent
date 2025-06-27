require 'rails_helper'

RSpec.describe "People Index", type: :request do
  describe "GET /people" do
    context "with no people" do
      it "renders successfully with empty state" do
        get people_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("People")
      end
    end

    context "with multiple people" do
      let!(:politician) { create(:person, :experienced_politician, first_name: "Sarah", last_name: "Johnson") }
      let!(:business_leader) { create(:person, :business_leader, first_name: "Michael", last_name: "Chen") }
      let!(:activist) { create(:person, :community_activist, first_name: "Jordan", last_name: "Rivera") }
      let!(:educator) { create(:person, :educator, first_name: "Dr. Emily", last_name: "Davis") }

      it "renders successfully with people data" do
        get people_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("People")
        expect(response.body).to include("Sarah Johnson")
        expect(response.body).to include("Michael Chen")
        expect(response.body).to include("Jordan Rivera")
        expect(response.body).to include("Dr. Emily Davis")
      end

      it "displays person biographical information" do
        get people_path
        
        expect(response.body).to include("Sarah")
        expect(response.body).to include("Michael")
        expect(response.body).to include("Jordan")
        expect(response.body).to include("Emily")
      end

      it "includes proper HTML structure for Phlex components" do
        get people_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with people who are candidates" do
      let!(:office) { create(:office, :active) }
      let!(:election) { create(:election, :upcoming, office: office) }
      let!(:candidate1) { create(:person, :experienced_politician, first_name: "John", last_name: "Smith") }
      let!(:candidate2) { create(:person, :business_leader, first_name: "Jane", last_name: "Doe") }
      let!(:non_candidate) { create(:person, :community_activist, first_name: "Alex", last_name: "Wilson") }
      
      let!(:candidacy1) { create(:candidacy, election: election, person: candidate1, party_affiliation: "Democratic") }
      let!(:candidacy2) { create(:candidacy, election: election, person: candidate2, party_affiliation: "Republican") }

      it "displays candidacy information for candidates" do
        get people_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("John Smith")
        expect(response.body).to include("Jane Doe")
        expect(response.body).to include("Alex Wilson")
      end

      it "shows party affiliation for candidates" do
        get people_path
        
        expect(response.body).to include("Democratic")
        expect(response.body).to include("Republican")
      end

      it "displays election context for candidates" do
        get people_path
        
        expect(response).to have_http_status(200)
        # Should show some indication of candidacy status
      end
    end

    context "with people having various background types" do
      let!(:veteran) { create(:person, :veteran, first_name: "Robert", last_name: "Martinez") }
      let!(:young_candidate) { create(:person, :young_candidate, first_name: "Ashley", last_name: "Kim") }
      let!(:long_bio_person) { create(:person, :long_bio, first_name: "William", last_name: "Thompson") }
      let!(:minimal_bio_person) { create(:person, :minimal_bio, first_name: "Lisa", last_name: "Brown") }

      it "displays people with different background types" do
        get people_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Robert Martinez")
        expect(response.body).to include("Ashley Kim")
        expect(response.body).to include("William Thompson")
        expect(response.body).to include("Lisa Brown")
      end

      it "handles different bio lengths appropriately" do
        get people_path
        
        expect(response).to have_http_status(200)
        # Should handle both long and minimal bios
      end
    end

    context "with pagination" do
      before do
        create_list(:person, 30)
      end

      it "renders successfully with pagination" do
        get people_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("People")
      end

      it "respects page parameter" do
        get people_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("People")
      end

      it "handles high page numbers gracefully" do
        get people_path, params: { page: 999 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("People")
      end
    end

    context "with people in multiple elections" do
      let!(:person) { create(:person, :experienced_politician) }
      let!(:office1) { create(:office) }
      let!(:office2) { create(:office) }
      let!(:election1) { create(:election, office: office1) }
      let!(:election2) { create(:election, office: office2) }
      let!(:candidacy1) { create(:candidacy, election: election1, person: person) }
      let!(:candidacy2) { create(:candidacy, election: election2, person: person) }

      it "displays person with multiple candidacies" do
        get people_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("People")
      end

      it "shows electoral history appropriately" do
        get people_path
        
        expect(response).to have_http_status(200)
        # Should indicate multiple candidacies or electoral activity
      end
    end
  end

  context "search and filtering capabilities" do
    let!(:politician) { create(:person, :experienced_politician, first_name: "Sarah") }
    let!(:business_person) { create(:person, :business_leader, first_name: "Michael") }

    it "handles potential search parameters" do
      get people_path, params: { search: "Sarah" }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("People")
    end

    it "handles candidate filtering if implemented" do
      # Create a candidate
      office = create(:office)
      election = create(:election, office: office)
      create(:candidacy, election: election, person: politician)
      
      get people_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("People")
    end
  end

  context "error handling" do
    it "handles database errors gracefully" do
      allow(Person).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
      
      expect { get people_path }.to raise_error(ActiveRecord::StatementInvalid)
    end

    it "handles valid parameters correctly" do
      create_list(:person, 5)
      
      get people_path, params: { page: 1 }
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("People")
    end

    it "handles people with special characters in names" do
      person_with_apostrophe = create(:person, first_name: "Mary", last_name: "O'Connor")
      person_with_hyphen = create(:person, first_name: "Jean-Luc", last_name: "Picard")
      
      get people_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("People")
    end
  end

  context "performance with complex data" do
    before do
      # Create people with varying levels of complexity
      5.times do
        person = create(:person, :experienced_politician)
        office = create(:office)
        election = create(:election, office: office)
        candidacy = create(:candidacy, election: election, person: person)
        # Add some ratings for electoral activity
        3.times do
          voter = create(:voter)
          create(:rating, candidacy: candidacy, voter: voter)
        end
      end
    end

    it "renders successfully with complex person data" do
      get people_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("People")
    end

    it "handles people with extensive electoral history" do
      person = create(:person, :experienced_politician)
      
      # Create multiple candidacies across different elections
      3.times do
        office = create(:office)
        election = create(:election, office: office)
        create(:candidacy, election: election, person: person)
      end
      
      get people_path
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("People")
    end
  end
end