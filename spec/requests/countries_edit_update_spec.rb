require 'rails_helper'

RSpec.describe "Countries Edit/Update", type: :request do
  let!(:country) { create(:country, name: "United States", abbreviation: "US") }

  describe "GET /countries/:id/edit" do
    it "renders the edit form successfully" do
      get edit_country_path(country)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Edit Country")
      expect(response.body).to include("United States")
      expect(response.body).to include("US")
    end

    it "includes proper form structure for Phlex components" do
      get edit_country_path(country)
      
      expect(response.body).to include("<form")
      expect(response.body).to include("</form>")
      expect(response.body).to include('name="country[name]"')
      expect(response.body).to include('name="country[abbreviation]"')
    end

    context "with non-existent country" do
      it "returns 404" do
        expect {
          get edit_country_path(99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PUT/PATCH /countries/:id" do
    context "with valid parameters" do
      let(:valid_attributes) {
        {
          name: "Canada",
          abbreviation: "CA"
        }
      }

      it "updates the country and redirects" do
        patch country_path(country), params: { country: valid_attributes }
        
        expect(response).to have_http_status(302)
        country.reload
        expect(country.name).to eq("Canada")
        expect(country.abbreviation).to eq("CA")
      end

      it "redirects to the country show page" do
        patch country_path(country), params: { country: valid_attributes }
        
        expect(response).to redirect_to(country_path(country))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        {
          name: "",
          abbreviation: ""
        }
      }

      it "does not update the country" do
        original_name = country.name
        patch country_path(country), params: { country: invalid_attributes }
        
        country.reload
        expect(country.name).to eq(original_name)
      end

      it "renders the edit template with errors" do
        patch country_path(country), params: { country: invalid_attributes }
        
        expect(response).to have_http_status(422)
        expect(response.body).to include("Edit Country")
      end
    end

    context "with non-existent country" do
      it "returns 404" do
        expect {
          patch country_path(99999), params: { country: { name: "Test" } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end