require 'rails_helper'

RSpec.describe "Official Codes Index", type: :request do
  describe "GET /official_codes" do
    context "with no official codes" do
      it "renders successfully with empty state" do
        get official_codes_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Official Codes")
      end
    end

    context "with multiple official codes" do
      let!(:code1) { create(:official_code, name: "Municipal Code 123-A", description: "Housing and zoning regulations", code_text: "Section 1: All residential buildings must...") }
      let!(:code2) { create(:official_code, name: "State Statute 45.2", description: "Environmental protection standards", code_text: "Chapter 2: Water quality standards shall...") }
      let!(:code3) { create(:official_code, name: "Federal Regulation CFR-789", description: "Healthcare privacy requirements", code_text: "Part 3: Patient information must be...") }

      it "renders successfully with official code data" do
        get official_codes_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Official Codes")
        expect(response.body).to include("Municipal Code 123-A")
        expect(response.body).to include("State Statute 45.2")
        expect(response.body).to include("Federal Regulation CFR-789")
      end

      it "displays official code descriptions" do
        get official_codes_path
        
        expect(response.body).to include("Housing and zoning")
        expect(response.body).to include("Environmental protection")
        expect(response.body).to include("Healthcare privacy")
      end

      it "includes proper HTML structure for Phlex components" do
        get official_codes_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with official codes having different jurisdictions" do
      let!(:municipal_code) { create(:official_code, name: "City Ordinance 001", jurisdiction: "Municipal") }
      let!(:state_code) { create(:official_code, name: "State Code 202", jurisdiction: "State") }
      let!(:federal_code) { create(:official_code, name: "Federal Law 303", jurisdiction: "Federal") }

      it "displays codes with jurisdiction information" do
        get official_codes_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("City Ordinance 001")
        expect(response.body).to include("State Code 202")
        expect(response.body).to include("Federal Law 303")
      end
    end

    context "with pagination" do
      before do
        create_list(:official_code, 30)
      end

      it "renders successfully with pagination" do
        get official_codes_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Official Codes")
      end

      it "respects page parameter" do
        get official_codes_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Official Codes")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(OfficialCode).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get official_codes_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end