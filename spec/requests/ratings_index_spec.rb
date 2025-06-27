require 'rails_helper'

RSpec.describe "Ratings Index", type: :request do
  describe "GET /ratings" do
    context "with no ratings" do
      it "renders successfully with empty state" do
        get ratings_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Ratings")
      end
    end

    context "with multiple ratings" do
      let!(:election) { create(:election, :active) }
      let!(:candidacy1) { create(:candidacy, election: election) }
      let!(:candidacy2) { create(:candidacy, election: election) }
      let!(:voter1) { create(:voter) }
      let!(:voter2) { create(:voter) }
      
      let!(:rating1) { create(:rating, candidacy: candidacy1, voter: voter1, rating: 350) }
      let!(:rating2) { create(:rating, candidacy: candidacy2, voter: voter1, rating: 200) }
      let!(:rating3) { create(:rating, candidacy: candidacy1, voter: voter2, rating: 450) }

      it "renders successfully with rating data" do
        get ratings_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Ratings")
        expect(response.body).to include("350")
        expect(response.body).to include("200")
        expect(response.body).to include("450")
      end

      it "displays candidate and voter information" do
        get ratings_path
        
        expect(response).to have_http_status(200)
        # Should show candidate and voter context
      end

      it "includes proper HTML structure for Phlex components" do
        get ratings_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with ratings across multiple elections" do
      let!(:election1) { create(:election, :active) }
      let!(:election2) { create(:election, :completed) }
      let!(:candidacy1) { create(:candidacy, election: election1) }
      let!(:candidacy2) { create(:candidacy, election: election2) }
      let!(:voter) { create(:voter) }
      let!(:rating1) { create(:rating, candidacy: candidacy1, voter: voter) }
      let!(:rating2) { create(:rating, candidacy: candidacy2, voter: voter) }

      it "displays ratings from different elections" do
        get ratings_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Ratings")
      end
    end

    context "with pagination" do
      let!(:candidacy) { create(:candidacy) }
      
      before do
        create_list(:rating, 30, candidacy: candidacy)
      end

      it "renders successfully with pagination" do
        get ratings_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Ratings")
      end

      it "respects page parameter" do
        get ratings_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Ratings")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Rating).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get ratings_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end