require 'rails_helper'

RSpec.describe "Governing Bodies Index", type: :request do
  describe "GET /governing_bodies" do
    context "with no governing bodies" do
      it "renders successfully with empty state" do
        get governing_bodies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governing Bodies")
      end
    end

    context "with multiple governing bodies" do
      let!(:city_council) { create(:governing_body, name: "San Francisco City Council", description: "Municipal legislative body") }
      let!(:state_legislature) { create(:governing_body, name: "California State Legislature", description: "State legislative assembly") }
      let!(:federal_congress) { create(:governing_body, name: "U.S. Congress", description: "Federal legislative branch") }

      it "renders successfully with governing body data" do
        get governing_bodies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governing Bodies")
        expect(response.body).to include("San Francisco City Council")
        expect(response.body).to include("California State Legislature")
        expect(response.body).to include("U.S. Congress")
      end

      it "displays governing body descriptions" do
        get governing_bodies_path
        
        expect(response.body).to include("Municipal legislative")
        expect(response.body).to include("State legislative")
        expect(response.body).to include("Federal legislative")
      end

      it "includes proper HTML structure for Phlex components" do
        get governing_bodies_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with pagination" do
      before do
        create_list(:governing_body, 30)
      end

      it "renders successfully with pagination" do
        get governing_bodies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governing Bodies")
      end

      it "respects page parameter" do
        get governing_bodies_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governing Bodies")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(GoverningBody).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get governing_bodies_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end