require 'rails_helper'

RSpec.describe "Policies Edit/Update", type: :request do
  let!(:policy) { create(:policy, title: "Healthcare Reform", summary: "Expanding access to healthcare", content: "Detailed policy content...") }

  describe "GET /policies/:id/edit" do
    it "renders the edit form successfully" do
      get edit_policy_path(policy)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Edit Policy")
      expect(response.body).to include("Healthcare Reform")
      expect(response.body).to include("Expanding access")
    end

    it "includes proper form structure for Phlex components" do
      get edit_policy_path(policy)
      
      expect(response.body).to include("<form")
      expect(response.body).to include("</form>")
      expect(response.body).to include('name="policy[title]"')
      expect(response.body).to include('name="policy[summary]"')
      expect(response.body).to include('name="policy[content]"')
    end

    context "with non-existent policy" do
      it "returns 404" do
        expect {
          get edit_policy_path(99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PUT/PATCH /policies/:id" do
    context "with valid parameters" do
      let(:valid_attributes) {
        {
          title: "Education Reform",
          summary: "Improving public education funding",
          content: "Comprehensive education policy details...",
          status: "draft"
        }
      }

      it "updates the policy and redirects" do
        patch policy_path(policy), params: { policy: valid_attributes }
        
        expect(response).to have_http_status(302)
        policy.reload
        expect(policy.title).to eq("Education Reform")
        expect(policy.summary).to eq("Improving public education funding")
        expect(policy.content).to eq("Comprehensive education policy details...")
        expect(policy.status).to eq("draft")
      end

      it "redirects to the policy show page" do
        patch policy_path(policy), params: { policy: valid_attributes }
        
        expect(response).to redirect_to(policy_path(policy))
      end
    end

    context "with status changes" do
      it "allows updating policy status" do
        patch policy_path(policy), params: { 
          policy: { status: "published" } 
        }
        
        policy.reload
        expect(policy.status).to eq("published")
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) {
        {
          title: "",
          summary: "",
          content: ""
        }
      }

      it "does not update the policy" do
        original_title = policy.title
        patch policy_path(policy), params: { policy: invalid_attributes }
        
        policy.reload
        expect(policy.title).to eq(original_title)
      end

      it "renders the edit template with errors" do
        patch policy_path(policy), params: { policy: invalid_attributes }
        
        expect(response).to have_http_status(422)
        expect(response.body).to include("Edit Policy")
      end
    end

    context "with duplicate title" do
      let!(:other_policy) { create(:policy, title: "Unique Policy Title") }

      it "prevents duplicate policy titles" do
        patch policy_path(policy), params: { 
          policy: { title: "Unique Policy Title" } 
        }
        
        expect(response).to have_http_status(422)
        policy.reload
        expect(policy.title).not_to eq("Unique Policy Title")
      end
    end

    context "with non-existent policy" do
      it "returns 404" do
        expect {
          patch policy_path(99999), params: { policy: { title: "Test" } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end