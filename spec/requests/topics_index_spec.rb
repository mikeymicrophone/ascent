require 'rails_helper'

RSpec.describe "Topics Index", type: :request do
  describe "GET /topics" do
    context "with no topics" do
      it "renders successfully with empty state" do
        get topics_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Topics")
      end
    end

    context "with multiple topics" do
      let!(:area_healthcare) { create(:area_of_concern, name: "Healthcare") }
      let!(:area_education) { create(:area_of_concern, name: "Education") }
      let!(:topic1) { create(:topic, name: "Mental Health Services", description: "Access to mental health care", area_of_concern: area_healthcare) }
      let!(:topic2) { create(:topic, name: "Public School Funding", description: "Investment in K-12 education", area_of_concern: area_education) }
      let!(:topic3) { create(:topic, name: "Prescription Drug Costs", description: "Affordable medication access", area_of_concern: area_healthcare) }

      it "renders successfully with topic data" do
        get topics_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Topics")
        expect(response.body).to include("Mental Health Services")
        expect(response.body).to include("Public School Funding")
        expect(response.body).to include("Prescription Drug Costs")
      end

      it "displays topic descriptions and area of concerns" do
        get topics_path
        
        expect(response.body).to include("Access to mental health")
        expect(response.body).to include("Investment in K-12")
        expect(response.body).to include("Healthcare")
        expect(response.body).to include("Education")
      end

      it "includes proper HTML structure for Phlex components" do
        get topics_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with topics having issues" do
      let!(:topic) { create(:topic, name: "Climate Change") }
      let!(:issue1) { create(:issue, topic: topic) }
      let!(:issue2) { create(:issue, topic: topic) }

      it "displays topics with issue counts" do
        get topics_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Climate Change")
      end
    end

    context "with pagination" do
      let!(:area_of_concern) { create(:area_of_concern) }
      
      before do
        create_list(:topic, 30, area_of_concern: area_of_concern)
      end

      it "renders successfully with pagination" do
        get topics_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Topics")
      end

      it "respects page parameter" do
        get topics_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Topics")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Topic).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get topics_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end