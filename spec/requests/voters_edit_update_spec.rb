require 'rails_helper'

RSpec.describe "Voters Edit/Update", type: :request do
  let!(:voter) { create(:voter, first_name: "Sarah", last_name: "Johnson", email: "sarah@example.com") }

  describe "GET /voters/:id/edit" do
    it "renders the edit form successfully" do
      get edit_voter_path(voter)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Edit Voter")
      expect(response.body).to include("Sarah")
      expect(response.body).to include("Johnson")
      expect(response.body).to include("sarah@example.com")
    end

    it "includes proper form structure for Phlex components" do
      get edit_voter_path(voter)
      
      expect(response.body).to include("<form")
      expect(response.body).to include("</form>")
      expect(response.body).to include('name="voter[first_name]"')
      expect(response.body).to include('name="voter[last_name]"')
      expect(response.body).to include('name="voter[email]"')
    end

    context "with non-existent voter" do
      it "returns 404" do
        expect {
          get edit_voter_path(99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PUT/PATCH /voters/:id" do
    context "with valid parameters" do
      let(:valid_attributes) {
        {
          first_name: "Sarah Marie",
          last_name: "Johnson-Smith", 
          email: "sarah.marie@example.com",
          phone: "555-0123"
        }
      }

      it "updates the voter and redirects" do
        patch voter_path(voter), params: { voter: valid_attributes }
        
        expect(response).to have_http_status(302)
        voter.reload
        expect(voter.first_name).to eq("Sarah Marie")
        expect(voter.last_name).to eq("Johnson-Smith")
        expect(voter.email).to eq("sarah.marie@example.com")
        expect(voter.phone).to eq("555-0123")
      end

      it "redirects to the voter show page" do
        patch voter_path(voter), params: { voter: valid_attributes }
        
        expect(response).to redirect_to(voter_path(voter))
      end
    end

    context "with verification status changes" do
      it "allows updating verification status" do
        patch voter_path(voter), params: { 
          voter: { verification_status: "verified" } 
        }
        
        voter.reload
        expect(voter.verification_status).to eq("verified")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        {
          first_name: "",
          last_name: "",
          email: "invalid-email"
        }
      }

      it "does not update the voter" do
        original_first_name = voter.first_name
        patch voter_path(voter), params: { voter: invalid_attributes }
        
        voter.reload
        expect(voter.first_name).to eq(original_first_name)
      end

      it "renders the edit template with errors" do
        patch voter_path(voter), params: { voter: invalid_attributes }
        
        expect(response).to have_http_status(422)
        expect(response.body).to include("Edit Voter")
      end
    end

    context "with duplicate email" do
      let!(:other_voter) { create(:voter, email: "other@example.com") }

      it "prevents duplicate email addresses" do
        patch voter_path(voter), params: { 
          voter: { email: "other@example.com" } 
        }
        
        expect(response).to have_http_status(422)
        voter.reload
        expect(voter.email).not_to eq("other@example.com")
      end
    end

    context "with non-existent voter" do
      it "returns 404" do
        expect {
          patch voter_path(99999), params: { voter: { first_name: "Test" } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end