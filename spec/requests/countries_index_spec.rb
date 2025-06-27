require 'rails_helper'

RSpec.describe "Countries Index", type: :request do
  describe "GET /countries" do
    context "with no countries" do
      it "renders successfully with empty state" do
        get countries_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Countries")
      end
    end

    context "with multiple countries" do
      let!(:usa) { create(:country, name: "United States", code: "US", description: "Federal constitutional republic") }
      let!(:canada) { create(:country, name: "Canada", code: "CA", description: "Parliamentary democracy") }
      let!(:uk) { create(:country, name: "United Kingdom", code: "GB", description: "Constitutional monarchy") }

      it "renders successfully with country data" do
        get countries_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Countries")
        expect(response.body).to include("United States")
        expect(response.body).to include("Canada")
        expect(response.body).to include("United Kingdom")
      end

      it "includes country codes in the response" do
        get countries_path
        
        expect(response.body).to include("US")
        expect(response.body).to include("CA") 
        expect(response.body).to include("GB")
      end

      it "includes country descriptions" do
        get countries_path
        
        expect(response.body).to include("Federal constitutional republic")
        expect(response.body).to include("Parliamentary democracy")
        expect(response.body).to include("Constitutional monarchy")
      end

      it "includes proper HTML structure for Phlex components" do
        get countries_path
        
        # Test for semantic HTML structure that Phlex components should generate
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with pagination" do
      before do
        # Create enough countries to trigger pagination (assuming 25 per page)
        create_list(:country, 30)
      end

      it "renders successfully with pagination" do
        get countries_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Countries")
      end

      it "respects page parameter" do
        get countries_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Countries")
      end
    end

    context "error handling" do
      it "handles extremely high page numbers gracefully" do
        create(:country)  # Just one country
        get countries_path, params: { page: 999 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Countries")
      end
      
      it "handles valid page numbers" do
        create_list(:country, 5)
        get countries_path, params: { page: 1 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Countries")
      end
    end
  end
end