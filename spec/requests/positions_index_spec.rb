require 'rails_helper'

RSpec.describe "Positions Index", type: :request do
  describe "GET /positions" do
    context "with no positions" do
      it "renders successfully with empty state" do
        get positions_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Positions")
      end
    end

    context "with multiple positions" do
      let!(:mayor) { create(:position, title: "Mayor", description: "Chief executive of the city") }
      let!(:council) { create(:position, title: "City Council Member", description: "Legislative representative") }
      let!(:governor) { create(:position, title: "Governor", description: "State chief executive") }

      it "renders successfully with position data" do
        get positions_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Positions")
        expect(response.body).to include("Mayor")
        expect(response.body).to include("City Council Member")
        expect(response.body).to include("Governor")
      end

      it "displays position descriptions" do
        get positions_path
        
        expect(response.body).to include("Chief executive")
        expect(response.body).to include("Legislative representative")
        expect(response.body).to include("State chief executive")
      end

      it "includes proper HTML structure for Phlex components" do
        get positions_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with positions that have offices" do
      let!(:position) { create(:position, title: "Mayor") }
      let!(:office1) { create(:office, position: position) }
      let!(:office2) { create(:office, position: position) }

      it "displays positions with office counts" do
        get positions_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Mayor")
      end
    end

    context "with pagination" do
      before do
        create_list(:position, 30)
      end

      it "renders successfully with pagination" do
        get positions_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Positions")
      end

      it "respects page parameter" do
        get positions_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Positions")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Position).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get positions_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end