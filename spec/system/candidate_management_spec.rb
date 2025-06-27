require 'rails_helper'

RSpec.describe "Candidate Management", type: :system do
  before do
    driven_by(:rack_test)
  end

  let!(:country) { create(:country, name: "United States") }
  let!(:year) { create(:year, year: 2024) }
  let!(:office) { create(:office, name: "Governor of California") }
  let!(:election) { create(:election, :upcoming, office: office, year: year) }
  
  let!(:person) { create(:person, first_name: "Sarah", last_name: "Martinez", bio: "Experienced public servant") }

  describe "person registration and candidacy announcement" do
    it "shows person profiles in the system" do
      visit people_path
      
      expect(page).to have_content("People")
      expect(page).to have_content("Sarah Martinez")
    end

    it "displays person biographical information" do
      visit person_path(person)
      
      expect(page).to have_content("Sarah Martinez")
      expect(page).to have_content("Experienced public servant")
    end

    context "when person becomes a candidate" do
      let!(:candidacy) { create(:candidacy, :announced, person: person, election: election, announcement_date: 1.month.ago) }

      it "shows candidacy in the candidacies listing" do
        visit candidacies_path
        
        expect(page).to have_content("Candidacies")
        expect(page).to have_content("Sarah Martinez")
        expect(page).to have_content("Governor")
      end

      it "displays candidacy details" do
        visit candidacy_path(candidacy)
        
        expect(page).to have_content("Sarah Martinez")
        expect(page).to have_content("Governor of California")
        expect(page).to have_content("announced")
      end

      it "shows candidacy status transitions" do
        # Start as announced
        expect(candidacy.status).to eq("announced")
        
        # Can transition to active
        candidacy.update!(status: "active")
        visit candidacy_path(candidacy)
        expect(page).to have_content("active")
        
        # Can transition to withdrawn
        candidacy.update!(status: "withdrawn")
        visit candidacy_path(candidacy)
        expect(page).to have_content("withdrawn")
      end
    end
  end

  describe "multiple candidates in election" do
    let!(:candidate1) { create(:person, first_name: "Alice", last_name: "Johnson") }
    let!(:candidate2) { create(:person, first_name: "Bob", last_name: "Wilson") }
    let!(:candidate3) { create(:person, first_name: "Carol", last_name: "Davis") }
    
    let!(:candidacy1) { create(:candidacy, :active, person: candidate1, election: election) }
    let!(:candidacy2) { create(:candidacy, :active, person: candidate2, election: election) }
    let!(:candidacy3) { create(:candidacy, :withdrawn, person: candidate3, election: election) }

    it "shows all candidates for an election" do
      visit election_path(election)
      
      expect(page).to have_content("Alice Johnson")
      expect(page).to have_content("Bob Wilson")
      expect(page).to have_content("Carol Davis")
    end

    it "differentiates candidate statuses" do
      visit candidacies_path
      
      # Should show different statuses
      expect(page).to have_content("active")
      expect(page).to have_content("withdrawn")
    end

    it "filters candidates by status" do
      active_candidacies = election.candidacies.active
      expect(active_candidacies).to include(candidacy1, candidacy2)
      expect(active_candidacies).not_to include(candidacy3)
      
      withdrawn_candidacies = election.candidacies.withdrawn
      expect(withdrawn_candidacies).to include(candidacy3)
      expect(withdrawn_candidacies).not_to include(candidacy1, candidacy2)
    end
  end

  describe "candidate performance tracking" do
    let!(:candidacy) { create(:candidacy, :active, person: person, election: election) }
    let!(:voter1) { create(:voter) }
    let!(:voter2) { create(:voter) }
    let!(:voter3) { create(:voter) }

    context "with voter ratings" do
      before do
        create(:rating, voter: voter1, candidacy: candidacy, rating: 450)
        create(:rating, voter: voter2, candidacy: candidacy, rating: 300)
        create(:rating, voter: voter3, candidacy: candidacy, rating: 200)
      end

      it "calculates average ratings correctly" do
        expect(candidacy.average_rating).to eq(316.7) # (450 + 300 + 200) / 3 = 316.67, rounded to 316.7
      end

      it "shows approval counts based on baseline" do
        baseline_250 = 250
        expect(candidacy.approval_count(baseline_250)).to eq(2) # 450 and 300 are >= 250
        expect(candidacy.approval_percentage(baseline_250)).to eq(66.7) # 2/3 = 66.67%, rounded to 66.7%
        
        baseline_350 = 350
        expect(candidacy.approval_count(baseline_350)).to eq(1) # Only 450 is >= 350
        expect(candidacy.approval_percentage(baseline_350)).to eq(33.3) # 1/3 = 33.33%, rounded to 33.3%
      end

      it "displays rating information in the system" do
        visit ratings_path
        
        expect(page).to have_content("450")
        expect(page).to have_content("300")
        expect(page).to have_content("200")
      end
    end
  end

  describe "office and position context" do
    let!(:position) { create(:position, title: "Governor", description: "Chief executive of the state") }
    let!(:office_with_position) { create(:office, position: position, name: "Governor of California") }
    let!(:election_with_context) { create(:election, office: office_with_position, year: year) }
    let!(:candidacy) { create(:candidacy, person: person, election: election_with_context) }

    it "shows office and position information" do
      visit offices_path
      
      expect(page).to have_content("Governor of California")
      expect(page).to have_content("Governor")
    end

    it "shows position descriptions" do
      visit positions_path
      
      expect(page).to have_content("Governor")
      expect(page).to have_content("Chief executive")
    end

    it "links candidates to their office context" do
      expect(candidacy.name).to eq("Sarah Martinez for Governor")
    end
  end
end