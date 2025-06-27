require 'rails_helper'

RSpec.describe "Residences Index", type: :request do
  describe "GET /residences" do
    context "with no residences" do
      it "renders successfully with empty state" do
        get residences_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Residences")
      end
    end

    context "with multiple residences" do
      let!(:city1) { create(:city, name: "San Francisco") }
      let!(:city2) { create(:city, name: "Oakland") }
      let!(:voter1) { create(:voter, first_name: "Sarah", last_name: "Johnson") }
      let!(:voter2) { create(:voter, first_name: "Michael", last_name: "Chen") }
      let!(:voter3) { create(:voter, first_name: "Jordan", last_name: "Taylor") }
      
      let!(:residence1) { create(:residence, voter: voter1, city: city1, address: "123 Market St") }
      let!(:residence2) { create(:residence, voter: voter2, city: city2, address: "456 Broadway") }
      let!(:residence3) { create(:residence, voter: voter3, city: city1, address: "789 Mission St") }

      it "renders successfully with residence data" do
        get residences_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Residences")
        expect(response.body).to include("123 Market")
        expect(response.body).to include("456 Broadway")
        expect(response.body).to include("789 Mission")
      end

      it "displays voter and city information" do
        get residences_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Sarah Johnson")
        expect(response.body).to include("Michael Chen")
        expect(response.body).to include("San Francisco")
        expect(response.body).to include("Oakland")
      end

      it "includes proper HTML structure for Phlex components" do
        get residences_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with residences across multiple cities" do
      let!(:state) { create(:state, name: "California") }
      let!(:city1) { create(:city, state: state, name: "San Francisco") }
      let!(:city2) { create(:city, state: state, name: "Los Angeles") }
      let!(:voter) { create(:voter) }
      let!(:residence1) { create(:residence, voter: voter, city: city1) }
      let!(:residence2) { create(:residence, voter: voter, city: city2) }

      it "displays residences from different cities" do
        get residences_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Residences")
        expect(response.body).to include("San Francisco")
        expect(response.body).to include("Los Angeles")
      end
    end

    context "with pagination" do
      let!(:city) { create(:city) }
      
      before do
        create_list(:residence, 30, city: city)
      end

      it "renders successfully with pagination" do
        get residences_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Residences")
      end

      it "respects page parameter" do
        get residences_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Residences")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Residence).to receive(:includes).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get residences_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end
end