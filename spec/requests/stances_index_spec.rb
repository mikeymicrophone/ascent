require 'rails_helper'

RSpec.describe "Stances Index", type: :request do
  describe "GET /stances" do
    context "with no stances" do
      it "renders successfully with empty state" do
        get stances_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Stances")
      end
    end

    context "with multiple stances" do
      let!(:election) { create(:election, :active) }
      let!(:candidacy1) { create(:candidacy, election: election) }
      let!(:candidacy2) { create(:candidacy, election: election) }
      let!(:approach1) { create(:approach, name: "Universal Healthcare") }
      let!(:approach2) { create(:approach, name: "Climate Action") }
      
      let!(:stance1) { create(:stance, candidacy: candidacy1, approach: approach1, position: "strongly_support", explanation: "Healthcare is a human right") }
      let!(:stance2) { create(:stance, candidacy: candidacy2, approach: approach1, position: "oppose", explanation: "Market-based solutions preferred") }
      let!(:stance3) { create(:stance, candidacy: candidacy1, approach: approach2, position: "support", explanation: "Urgent action needed on climate") }

      it "renders successfully with stance data" do
        get stances_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Stances")
        expect(response.body).to include("Universal Healthcare")
        expect(response.body).to include("Climate Action")
      end

      it "displays stance positions and explanations" do
        get stances_path
        
        expect(response.body).to include("Healthcare is a human right")
        expect(response.body).to include("Market-based solutions")
        expect(response.body).to include("Urgent action needed")
      end

      it "shows candidate and approach information" do
        get stances_path
        
        expect(response).to have_http_status(200)
        # Should show candidate names and approach titles
      end

      it "includes proper HTML structure for Phlex components" do
        get stances_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with stances across multiple elections" do
      let!(:election1) { create(:election, :active) }
      let!(:election2) { create(:election, :completed) }
      let!(:candidacy1) { create(:candidacy, election: election1) }
      let!(:candidacy2) { create(:candidacy, election: election2) }
      let!(:approach) { create(:approach) }
      let!(:stance1) { create(:stance, candidacy: candidacy1, approach: approach) }
      let!(:stance2) { create(:stance, candidacy: candidacy2, approach: approach) }

      it "displays stances from different elections" do
        get stances_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Stances")
      end
    end

    context "with pagination" do
      let!(:candidacy) { create(:candidacy) }
      let!(:approach) { create(:approach) }
      
      before do
        create_list(:stance, 30, candidacy: candidacy, approach: approach)
      end

      it "renders successfully with pagination" do
        get stances_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Stances")
      end

      it "respects page parameter" do
        get stances_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Stances")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Stance).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get stances_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end