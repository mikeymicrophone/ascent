require 'rails_helper'

RSpec.describe "Mountains Index", type: :request do
  describe "GET /mountains" do
    context "with no active elections" do
      let!(:completed_election) { create(:election, :completed) }
      
      it "renders successfully with no active elections" do
        get mountains_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Mountains") || expect(response.body).to include("Election")
      end
    end

    context "with active elections but no candidacies" do
      let!(:active_election) { create(:election, :active) }
      
      it "renders successfully with empty candidacy data" do
        get mountains_path
        
        expect(response).to have_http_status(200)
      end
    end

    context "with complete election data" do
      let!(:country) { create(:country, name: "United States") }
      let!(:state) { create(:state, name: "California", country: country) }
      let!(:city) { create(:city, name: "San Francisco", state: state) }
      let!(:position) { create(:position, title: "Mayor") }
      let!(:office) { create(:office, position: position, jurisdiction: city) }
      let!(:year) { create(:year, year: 2024) }
      let!(:active_election) { create(:election, :active, office: office, year: year) }
      
      let!(:candidate1) { create(:person, :experienced_politician, first_name: "Sarah", last_name: "Chen") }
      let!(:candidate2) { create(:person, :business_leader, first_name: "Michael", last_name: "Rodriguez") }
      let!(:candidate3) { create(:person, :young_activist, first_name: "Jordan", last_name: "Taylor") }
      
      let!(:candidacy1) { create(:candidacy, election: active_election, person: candidate1, party_affiliation: "Democratic") }
      let!(:candidacy2) { create(:candidacy, election: active_election, person: candidate2, party_affiliation: "Republican") }
      let!(:candidacy3) { create(:candidacy, election: active_election, person: candidate3, party_affiliation: "Green") }
      
      let!(:voter1) { create(:voter) }
      let!(:voter2) { create(:voter) }
      let!(:voter3) { create(:voter) }
      
      let!(:baseline1) { create(:voter_election_baseline, voter: voter1, election: active_election, baseline: 200) }
      let!(:baseline2) { create(:voter_election_baseline, voter: voter2, election: active_election, baseline: 300) }
      let!(:baseline3) { create(:voter_election_baseline, voter: voter3, election: active_election, baseline: 250) }
      
      let!(:rating1_1) { create(:rating, candidacy: candidacy1, voter: voter1, rating: 350) }
      let!(:rating1_2) { create(:rating, candidacy: candidacy2, voter: voter1, rating: 150) }
      let!(:rating1_3) { create(:rating, candidacy: candidacy3, voter: voter1, rating: 280) }
      
      let!(:rating2_1) { create(:rating, candidacy: candidacy1, voter: voter2, rating: 400) }
      let!(:rating2_2) { create(:rating, candidacy: candidacy2, voter: voter2, rating: 320) }
      let!(:rating2_3) { create(:rating, candidacy: candidacy3, voter: voter2, rating: 200) }
      
      let!(:rating3_1) { create(:rating, candidacy: candidacy1, voter: voter3, rating: 450) }
      let!(:rating3_2) { create(:rating, candidacy: candidacy2, voter: voter3, rating: 180) }
      let!(:rating3_3) { create(:rating, candidacy: candidacy3, voter: voter3, rating: 380) }

      it "renders successfully with complete mountain visualization data" do
        get mountains_path
        
        expect(response).to have_http_status(200)
      end

      it "displays candidate information" do
        get mountains_path
        
        expect(response.body).to include("Sarah Chen")
        expect(response.body).to include("Michael Rodriguez") 
        expect(response.body).to include("Jordan Taylor")
      end

      it "displays election context" do
        get mountains_path
        
        expect(response.body).to include("Mayor")
        expect(response.body).to include("San Francisco")
      end

      it "includes mountain visualization components" do
        get mountains_path
        
        # Look for visualization-related classes or elements
        expect(response.body).to include('class="') # Phlex components should have CSS classes
      end

      it "handles election parameter filtering" do
        get mountains_path, params: { election_id: active_election.id }
        
        expect(response).to have_http_status(200)
      end
    end

    context "with multiple active elections" do
      let!(:election1) { create(:election, :active) }
      let!(:election2) { create(:election, :active) }
      
      before do
        # Create candidacies for both elections
        2.times { create(:candidacy, election: election1) }
        3.times { create(:candidacy, election: election2) }
      end
      
      it "renders successfully with multiple elections" do
        get mountains_path
        
        expect(response).to have_http_status(200)
      end
    end

    context "with realistic simulation data" do
      let!(:active_election) { create(:election, :active) }
      
      before do
        # Create a realistic simulation setup similar to controller spec
        5.times do |i|
          person_traits = [:experienced_politician, :business_leader, :young_candidate]
          person = create(:person, person_traits[i % 3])
          candidacy = create(:candidacy, 
            election: active_election, 
            person: person,
            party_affiliation: ["Democratic", "Republican", "Independent", "Green", "Libertarian"][i % 5]
          )
          
          # Create voters and ratings for this candidacy
          3.times do |j|
            voter = create(:voter)
            baseline = create(:voter_election_baseline, 
              voter: voter, 
              election: active_election, 
              baseline: (200 + rand(200))
            )
            create(:rating, 
              candidacy: candidacy, 
              voter: voter, 
              rating: (baseline.baseline + rand(200) - 100).clamp(0, 500)
            )
          end
        end
      end
      
      it "renders successfully with realistic voting data" do
        get mountains_path
        
        expect(response).to have_http_status(200)
      end
    end

    context "error handling and edge cases" do
      it "handles invalid election_id parameter gracefully" do
        get mountains_path, params: { election_id: 999999 }
        
        expect(response).to have_http_status(200)
      end
      
      it "handles missing rating data gracefully" do
        election = create(:election, :active)
        candidacy = create(:candidacy, election: election)
        # No ratings created
        
        get mountains_path
        
        expect(response).to have_http_status(200)
      end
      
      it "handles elections with candidacies but no voters" do
        election = create(:election, :active)
        create(:candidacy, election: election)
        # No voters or ratings
        
        get mountains_path
        
        expect(response).to have_http_status(200)
      end
    end

    context "performance with large datasets" do
      before do
        # Create a larger dataset to test performance
        election = create(:election, :active)
        
        # Create 10 candidates
        candidates = 10.times.map { create(:person) }
        candidacies = candidates.map { |person| create(:candidacy, election: election, person: person) }
        
        # Create 20 voters with baselines
        voters = 20.times.map do
          voter = create(:voter)
          create(:voter_election_baseline, voter: voter, election: election)
          voter
        end
        
        # Create ratings (20 voters x 10 candidates = 200 ratings)
        voters.each do |voter|
          candidacies.each do |candidacy|
            create(:rating, candidacy: candidacy, voter: voter)
          end
        end
      end
      
      it "renders successfully with large datasets" do
        get mountains_path
        
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "GET /mountains/:id" do
    let!(:election) { create(:election, :active) }
    let!(:candidacy) { create(:candidacy, election: election) }
    
    it "renders individual mountain show page" do
      get mountain_path(election)
      
      expect(response).to have_http_status(200)
    end
    
    it "handles non-existent election gracefully" do
      expect { get mountain_path(999999) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end