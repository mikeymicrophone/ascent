require 'rails_helper'

RSpec.describe "Elections Edit/Update", type: :request do
  let!(:country) { create(:country) }
  let!(:year) { create(:year) }
  let!(:election) { create(:election, name: "2024 Presidential Election", country: country, year: year) }

  describe "GET /elections/:id/edit" do
    it "renders the edit form successfully" do
      get edit_election_path(election)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Edit Election")
      expect(response.body).to include("2024 Presidential Election")
    end

    it "includes proper form structure for Phlex components" do
      get edit_election_path(election)
      
      expect(response.body).to include("<form")
      expect(response.body).to include("</form>")
      expect(response.body).to include('name="election[name]"')
    end

    context "with non-existent election" do
      it "returns 404" do
        expect {
          get edit_election_path(99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PUT/PATCH /elections/:id" do
    context "with valid parameters" do
      let(:valid_attributes) {
        {
          name: "2024 Congressional Elections",
          description: "Midterm elections for Congress"
        }
      }

      it "updates the election and redirects" do
        patch election_path(election), params: { election: valid_attributes }
        
        expect(response).to have_http_status(302)
        election.reload
        expect(election.name).to eq("2024 Congressional Elections")
        expect(election.description).to eq("Midterm elections for Congress")
      end

      it "redirects to the election show page" do
        patch election_path(election), params: { election: valid_attributes }
        
        expect(response).to redirect_to(election_path(election))
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        {
          name: "",
          year_id: nil
        }
      }

      it "does not update the election" do
        original_name = election.name
        patch election_path(election), params: { election: invalid_attributes }
        
        election.reload
        expect(election.name).to eq(original_name)
      end

      it "renders the edit template with errors" do
        patch election_path(election), params: { election: invalid_attributes }
        
        expect(response).to have_http_status(422)
        expect(response.body).to include("Edit Election")
      end
    end

    context "with status changes" do
      it "allows updating election status" do
        patch election_path(election), params: { 
          election: { status: "completed" } 
        }
        
        election.reload
        expect(election.status).to eq("completed")
      end
    end

    context "with non-existent election" do
      it "returns 404" do
        expect {
          patch election_path(99999), params: { election: { name: "Test" } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end