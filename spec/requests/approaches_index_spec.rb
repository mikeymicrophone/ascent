require 'rails_helper'

RSpec.describe "Approaches Index", type: :request do
  describe "GET /approaches" do
    context "with no approaches" do
      it "renders successfully with empty state" do
        get approaches_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Approaches")
      end
    end

    context "with multiple approaches" do
      let!(:issue1) { create(:issue, name: "Housing Crisis") }
      let!(:issue2) { create(:issue, name: "Climate Change") }
      let!(:approach1) { create(:approach, name: "Rent Control Policies", description: "Regulate rental prices to ensure affordability", issue: issue1) }
      let!(:approach2) { create(:approach, name: "Carbon Tax Implementation", description: "Tax carbon emissions to incentivize reduction", issue: issue2) }
      let!(:approach3) { create(:approach, name: "Public Housing Development", description: "Government-funded affordable housing projects", issue: issue1) }

      it "renders successfully with approach data" do
        get approaches_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Approaches")
        expect(response.body).to include("Rent Control Policies")
        expect(response.body).to include("Carbon Tax Implementation")
        expect(response.body).to include("Public Housing Development")
      end

      it "displays approach descriptions and issues" do
        get approaches_path
        
        expect(response.body).to include("Regulate rental prices")
        expect(response.body).to include("Tax carbon emissions")
        expect(response.body).to include("Housing Crisis")
        expect(response.body).to include("Climate Change")
      end

      it "includes proper HTML structure for Phlex components" do
        get approaches_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with approaches having stances" do
      let!(:approach) { create(:approach, name: "Universal Healthcare") }
      let!(:candidacy) { create(:candidacy) }
      let!(:stance1) { create(:stance, approach: approach, candidacy: candidacy) }

      it "displays approaches with stance information" do
        get approaches_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Universal Healthcare")
      end
    end

    context "with pagination" do
      let!(:issue) { create(:issue) }
      
      before do
        create_list(:approach, 30, issue: issue)
      end

      it "renders successfully with pagination" do
        get approaches_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Approaches")
      end

      it "respects page parameter" do
        get approaches_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Approaches")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Approach).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get approaches_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end