require 'rails_helper'

RSpec.describe "Voting Workflow", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:country) { create(:country, name: "United States") }
  let!(:year) { create(:year, year: 2024) }
  let!(:office) { create(:office, name: "Mayor of Springfield") }
  let!(:election) { create(:election, :active, office: office, year: year) }
  
  let!(:candidate1) { create(:person, first_name: "Alice", last_name: "Johnson") }
  let!(:candidate2) { create(:person, first_name: "Bob", last_name: "Smith") }
  let!(:candidacy1) { create(:candidacy, :active, person: candidate1, election: election) }
  let!(:candidacy2) { create(:candidacy, :active, person: candidate2, election: election) }
  
  let!(:voter) { create(:voter, first_name: "Jane", last_name: "Voter") }
  let!(:baseline) { create(:voter_election_baseline, voter: voter, election: election, baseline: 250) }

  describe "voter browsing elections and viewing candidates" do
    it "allows voter to view active elections" do
      visit elections_path
      
      expect(page).to have_content("Elections")
      expect(page).to have_content("Mayor of Springfield")
      expect(page).to have_content("2024")
    end

    it "shows election details with candidates" do
      visit election_path(election)
      
      expect(page).to have_content("Mayor of Springfield")
      expect(page).to have_content("Alice Johnson")
      expect(page).to have_content("Bob Smith")
    end

    it "displays candidacy information" do
      visit candidacy_path(candidacy1)
      
      expect(page).to have_content("Alice Johnson")
      expect(page).to have_content("Mayor")
    end
  end

  describe "voter rating candidates" do
    context "when voter creates ratings" do
      let!(:rating1) { create(:rating, voter: voter, candidacy: candidacy1, rating: 350) }
      let!(:rating2) { create(:rating, voter: voter, candidacy: candidacy2, rating: 200) }

      it "shows voter ratings in the system" do
        visit ratings_path
        
        expect(page).to have_content("Ratings")
        expect(page).to have_content("350")
        expect(page).to have_content("200")
      end

      it "reflects ratings in election results" do
        # Alice should have 1 approval vote (350 >= 250 baseline)
        # Bob should have 0 approval votes (200 < 250 baseline)
        results = election.aggregate_votes
        
        expect(results[candidacy1]).to eq(1)
        expect(results[candidacy2]).to eq(0)
        expect(election.approval_winner).to eq(candidacy1)
      end
    end
  end

  describe "viewing people and candidates" do
    it "shows all people in the system" do
      visit people_path
      
      expect(page).to have_content("People")
      expect(page).to have_content("Alice Johnson")
      expect(page).to have_content("Bob Smith")
    end

    it "shows candidacies for people" do
      visit candidacies_path
      
      expect(page).to have_content("Candidacies")
      expect(page).to have_content("Alice Johnson")
      expect(page).to have_content("Bob Smith")
      expect(page).to have_content("Mayor")
    end
  end

  describe "voter information" do
    it "shows voter profiles" do
      visit voters_path
      
      expect(page).to have_content("Voters")
      expect(page).to have_content("Jane Voter")
    end

    it "shows voter baselines" do
      visit voter_election_baselines_path
      
      expect(page).to have_content("Baselines")
      expect(page).to have_content("Jane Voter")
      expect(page).to have_content("250")
    end
  end

  describe "geographical navigation" do
    let!(:state) { create(:state, name: "Illinois", country: country) }
    let!(:city) { create(:city, name: "Springfield", state: state) }

    it "allows browsing from countries to states to cities" do
      visit countries_path
      expect(page).to have_content("United States")
      
      visit states_path
      expect(page).to have_content("Illinois")
      
      visit cities_path
      expect(page).to have_content("Springfield")
    end
  end

  describe "complete voting scenario" do
    let!(:other_voter) { create(:voter, first_name: "John", last_name: "Citizen") }
    let!(:other_baseline) { create(:voter_election_baseline, voter: other_voter, election: election, baseline: 300) }
    
    it "demonstrates approval voting with multiple voters" do
      # Create ratings for both voters
      create(:rating, voter: voter, candidacy: candidacy1, rating: 400)      # Above Jane's baseline (250) ✓
      create(:rating, voter: voter, candidacy: candidacy2, rating: 200)      # Below Jane's baseline (250) ✗
      
      create(:rating, voter: other_voter, candidacy: candidacy1, rating: 350) # Above John's baseline (300) ✓  
      create(:rating, voter: other_voter, candidacy: candidacy2, rating: 450) # Above John's baseline (300) ✓

      # Calculate election results
      results = election.aggregate_votes
      
      # Alice should win with 2 approval votes (both voters approved)
      # Bob should have 1 approval vote (only John approved)
      expect(results[candidacy1]).to eq(2) # Alice - winner
      expect(results[candidacy2]).to eq(1) # Bob
      
      expect(election.approval_winner).to eq(candidacy1)
      
      # Check results summary
      summary = election.results_summary
      expect(summary[:total_candidacies]).to eq(2)
      expect(summary[:total_registered_voters]).to eq(2)
      expect(summary[:total_approval_votes]).to eq(3) # Jane: 1 vote, John: 2 votes
      expect(summary[:winner]).to eq("Alice Johnson")
      expect(summary[:winning_vote_count]).to eq(2)
    end
  end
end