require 'rails_helper'

RSpec.describe "People Edit/Update", type: :request do
  let!(:person) { create(:person, first_name: "John", last_name: "Smith", email: "john@example.com") }

  describe "GET /people/:id/edit" do
    it "renders the edit form successfully" do
      get edit_person_path(person)
      
      expect(response).to have_http_status(200)
      expect(response.body).to include("Edit Person")
      expect(response.body).to include("John")
      expect(response.body).to include("Smith")
      expect(response.body).to include("john@example.com")
    end

    it "includes proper form structure for Phlex components" do
      get edit_person_path(person)
      
      expect(response.body).to include("<form")
      expect(response.body).to include("</form>")
      expect(response.body).to include('name="person[first_name]"')
      expect(response.body).to include('name="person[last_name]"')
      expect(response.body).to include('name="person[email]"')
    end

    context "with non-existent person" do
      it "returns 404" do
        expect {
          get edit_person_path(99999)
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "PUT/PATCH /people/:id" do
    context "with valid parameters" do
      let(:valid_attributes) {
        {
          first_name: "Jane",
          last_name: "Doe",
          email: "jane@example.com",
          bio: "Experienced public servant"
        }
      }

      it "updates the person and redirects" do
        patch person_path(person), params: { person: valid_attributes }
        
        expect(response).to have_http_status(302)
        person.reload
        expect(person.first_name).to eq("Jane")
        expect(person.last_name).to eq("Doe")
        expect(person.email).to eq("jane@example.com")
        expect(person.bio).to eq("Experienced public servant")
      end

      it "redirects to the person show page" do
        patch person_path(person), params: { person: valid_attributes }
        
        expect(response).to redirect_to(person_path(person))
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

      it "does not update the person" do
        original_first_name = person.first_name
        patch person_path(person), params: { person: invalid_attributes }
        
        person.reload
        expect(person.first_name).to eq(original_first_name)
      end

      it "renders the edit template with errors" do
        patch person_path(person), params: { person: invalid_attributes }
        
        expect(response).to have_http_status(422)
        expect(response.body).to include("Edit Person")
      end
    end

    context "with duplicate email" do
      let!(:other_person) { create(:person, email: "other@example.com") }

      it "prevents duplicate email addresses" do
        patch person_path(person), params: { 
          person: { email: "other@example.com" } 
        }
        
        expect(response).to have_http_status(422)
        person.reload
        expect(person.email).not_to eq("other@example.com")
      end
    end

    context "with non-existent person" do
      it "returns 404" do
        expect {
          patch person_path(99999), params: { person: { first_name: "Test" } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end