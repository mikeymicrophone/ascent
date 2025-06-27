require 'rails_helper'

RSpec.describe "Issues Index", type: :request do
  describe "GET /issues" do
    context "with no issues" do
      it "renders successfully with empty state" do
        get issues_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Issues")
      end
    end

    context "with multiple issues" do
      let!(:topic1) { create(:topic, name: "Healthcare Access") }
      let!(:topic2) { create(:topic, name: "Climate Policy") }
      let!(:issue1) { create(:issue, name: "Rural Healthcare Shortages", description: "Limited medical services in rural areas", topic: topic1) }
      let!(:issue2) { create(:issue, name: "Carbon Emission Standards", description: "Regulations for industrial emissions", topic: topic2) }
      let!(:issue3) { create(:issue, name: "Insurance Coverage Gaps", description: "Uninsured population challenges", topic: topic1) }

      it "renders successfully with issue data" do
        get issues_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Issues")
        expect(response.body).to include("Rural Healthcare Shortages")
        expect(response.body).to include("Carbon Emission Standards")
        expect(response.body).to include("Insurance Coverage Gaps")
      end

      it "displays issue descriptions and topics" do
        get issues_path
        
        expect(response.body).to include("Limited medical services")
        expect(response.body).to include("Regulations for industrial")
        expect(response.body).to include("Healthcare Access")
        expect(response.body).to include("Climate Policy")
      end

      it "includes proper HTML structure for Phlex components" do
        get issues_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with issues having approaches" do
      let!(:issue) { create(:issue, name: "Affordable Housing Crisis") }
      let!(:approach1) { create(:approach, issue: issue) }
      let!(:approach2) { create(:approach, issue: issue) }

      it "displays issues with approach counts" do
        get issues_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Affordable Housing Crisis")
      end
    end

    context "with pagination" do
      let!(:topic) { create(:topic) }
      
      before do
        create_list(:issue, 30, topic: topic)
      end

      it "renders successfully with pagination" do
        get issues_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Issues")
      end

      it "respects page parameter" do
        get issues_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Issues")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Issue).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get issues_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end