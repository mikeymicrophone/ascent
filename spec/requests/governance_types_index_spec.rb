require 'rails_helper'

RSpec.describe "Governance Types Index", type: :request do
  describe "GET /governance_types" do
    context "with no governance types" do
      it "renders successfully with empty state" do
        get governance_types_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governance Types")
      end
    end

    context "with multiple governance types" do
      let!(:democracy) { create(:governance_type, name: "Democracy", description: "Government by the people") }
      let!(:republic) { create(:governance_type, name: "Republic", description: "Representative democracy") }
      let!(:monarchy) { create(:governance_type, name: "Constitutional Monarchy", description: "Limited monarchical system") }

      it "renders successfully with governance type data" do
        get governance_types_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governance Types")
        expect(response.body).to include("Democracy")
        expect(response.body).to include("Republic")
        expect(response.body).to include("Constitutional Monarchy")
      end

      it "displays governance type descriptions" do
        get governance_types_path
        
        expect(response.body).to include("Government by the people")
        expect(response.body).to include("Representative democracy")
        expect(response.body).to include("Limited monarchical")
      end

      it "includes proper HTML structure for Phlex components" do
        get governance_types_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with governance types having governing bodies" do
      let!(:governance_type) { create(:governance_type, name: "Parliamentary System") }
      let!(:body1) { create(:governing_body, governance_type: governance_type) }
      let!(:body2) { create(:governing_body, governance_type: governance_type) }

      it "displays governance types with governing body counts" do
        get governance_types_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Parliamentary System")
      end
    end

    context "with pagination" do
      before do
        create_list(:governance_type, 30)
      end

      it "renders successfully with pagination" do
        get governance_types_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governance Types")
      end

      it "respects page parameter" do
        get governance_types_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Governance Types")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(GovernanceType).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get governance_types_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end