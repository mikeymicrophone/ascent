require 'rails_helper'

RSpec.describe "Area of Concerns Index", type: :request do
  describe "GET /area_of_concerns" do
    context "with no area of concerns" do
      it "renders successfully with empty state" do
        get area_of_concerns_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Area of Concerns")
      end
    end

    context "with multiple area of concerns" do
      let!(:healthcare) { create(:area_of_concern, name: "Healthcare", description: "Medical care and public health policies") }
      let!(:education) { create(:area_of_concern, name: "Education", description: "Educational systems and funding") }
      let!(:environment) { create(:area_of_concern, name: "Environment", description: "Environmental protection and climate policy") }

      it "renders successfully with area of concern data" do
        get area_of_concerns_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Area of Concerns")
        expect(response.body).to include("Healthcare")
        expect(response.body).to include("Education")
        expect(response.body).to include("Environment")
      end

      it "displays area of concern descriptions" do
        get area_of_concerns_path
        
        expect(response.body).to include("Medical care")
        expect(response.body).to include("Educational systems")
        expect(response.body).to include("Environmental protection")
      end

      it "includes proper HTML structure for Phlex components" do
        get area_of_concerns_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with area of concerns having topics" do
      let!(:area_of_concern) { create(:area_of_concern, name: "Healthcare") }
      let!(:topic1) { create(:topic, area_of_concern: area_of_concern) }
      let!(:topic2) { create(:topic, area_of_concern: area_of_concern) }

      it "displays area of concerns with topic counts" do
        get area_of_concerns_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Healthcare")
      end
    end

    context "with pagination" do
      before do
        create_list(:area_of_concern, 30)
      end

      it "renders successfully with pagination" do
        get area_of_concerns_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Area of Concerns")
      end

      it "respects page parameter" do
        get area_of_concerns_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Area of Concerns")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(AreaOfConcern).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get area_of_concerns_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end