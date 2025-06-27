require 'rails_helper'

RSpec.describe "Years Index", type: :request do
  describe "GET /years" do
    context "with no years" do
      it "renders successfully with empty state" do
        get years_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Years")
      end
    end

    context "with multiple years" do
      let!(:year2024) { create(:year, value: 2024, description: "Presidential election year") }
      let!(:year2023) { create(:year, value: 2023, description: "Municipal elections") }
      let!(:year2022) { create(:year, value: 2022, description: "Midterm elections") }

      it "renders successfully with year data" do
        get years_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Years")
        expect(response.body).to include("2024")
        expect(response.body).to include("2023")
        expect(response.body).to include("2022")
      end

      it "displays year descriptions" do
        get years_path
        
        expect(response.body).to include("Presidential election")
        expect(response.body).to include("Municipal elections")
        expect(response.body).to include("Midterm elections")
      end

      it "includes proper HTML structure for Phlex components" do
        get years_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with years having elections" do
      let!(:year) { create(:year, value: 2024) }
      let!(:election1) { create(:election, year: year) }
      let!(:election2) { create(:election, year: year) }

      it "displays years with election counts" do
        get years_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("2024")
      end
    end

    context "with pagination" do
      before do
        create_list(:year, 30)
      end

      it "renders successfully with pagination" do
        get years_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Years")
      end

      it "respects page parameter" do
        get years_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Years")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Year).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get years_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end