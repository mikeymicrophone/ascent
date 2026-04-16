require 'rails_helper'

RSpec.describe "Policies Index", type: :request do
  describe "GET /policies" do
    context "with no policies" do
      it "renders successfully with empty state" do
        get policies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Policies")
      end
    end

    context "with multiple policies" do
      let!(:policy1) { create(:policy, title: "Healthcare Reform", description: "Expanding access to affordable healthcare") }
      let!(:policy2) { create(:policy, title: "Education Funding", description: "Increasing investment in public education") }
      let!(:policy3) { create(:policy, title: "Infrastructure Development", description: "Modernizing transportation systems") }

      it "renders successfully with policy data" do
        get policies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Policies")
        expect(response.body).to include("Healthcare Reform")
        expect(response.body).to include("Education Funding")
        expect(response.body).to include("Infrastructure Development")
      end

      it "displays policy summaries" do
        get policies_path
        
        expect(response.body).to include("Expanding access")
        expect(response.body).to include("Increasing investment")
        expect(response.body).to include("Modernizing transportation")
      end

      it "includes proper HTML structure for Phlex components" do
        get policies_path
        
        expect(response.body).to include('class="')
        expect(response.body).to include("<div")
        expect(response.body).to include("</div>")
      end
    end

    context "with pagination" do
      before do
        create_list(:policy, 30)
      end

      it "renders successfully with pagination" do
        get policies_path
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Policies")
      end

      it "respects page parameter" do
        get policies_path, params: { page: 2 }
        
        expect(response).to have_http_status(200)
        expect(response.body).to include("Policies")
      end
    end

    context "error handling" do
      it "handles database errors gracefully" do
        allow(Policy).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("Database error"))
        
        expect { get policies_path }.to raise_error(ActiveRecord::StatementInvalid)
      end
    end
  end

  describe "authorization" do
    let!(:policy) { create(:policy, title: "Authorization Test Policy") }

    it "allows public read access to the index" do
      get policies_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Authorization Test Policy")
    end

    it "redirects guests away from the new policy form" do
      get new_policy_path

      expect(response).to redirect_to(new_voter_session_path)
    end

    it "redirects non-admin voters away from the new policy form" do
      sign_in create(:voter)

      get new_policy_path

      expect(response).to redirect_to(root_path)
    end

    it "allows admin voters to reach the new policy form" do
      sign_in create(:admin_voter)

      get new_policy_path

      expect(response).to have_http_status(:ok)
    end
  end
end
