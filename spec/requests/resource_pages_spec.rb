require 'rails_helper'

# Reference data without a page of its own, such as positions and areas of concern, renders its index and
# show pages through the shared ResourceIndex and ResourceShow shells.
RSpec.describe "Resource index and show pages", type: :request do
  let(:admin) { create(:admin_voter) }

  describe "an index page" do
    let!(:council_member) { create(:position, title: "City Council Member") }
    let!(:mayor) { create(:position, :executive) }

    it "lists each record with its partial and actions inside the scaffold" do
      get positions_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('class="scaffold positions-index" id="index_positions"')
      expect(response.body).to include("<h1>Positions</h1>")
      expect(response.body).to include("id=\"list_item_position_#{mayor.id}\"")
      expect(response.body).to include("City Council Member", "Mayor")
    end

    it "offers the new link only to voters allowed to create" do
      get positions_path
      expect(response.body).not_to include("New position")

      sign_in admin
      get positions_path
      expect(response.body).to include(%(href="#{new_position_path}">New position</a>))
    end

    it "pages the records once there are more than a page of them" do
      create_list(:position, Pagy::OPTIONS[:limit])

      get positions_path

      expect(response.body).to include(%(<nav class="pagination" aria-label="Pagination">), "Showing 1–25 of")
      expect(response.body.scan(/id="list_item_position_\d+"/).size).to eq(Pagy::OPTIONS[:limit])
    end
  end

  it "names the empty state after the model" do
    get area_of_concerns_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No area of concerns found.")
  end

  describe "a show page" do
    it "wraps the record's partial with a heading and its actions" do
      area = create(:area_of_concern, :housing)

      get area_of_concern_path(area)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("class=\"scaffold area_of_concern-show\" id=\"show_area_of_concern_#{area.id}\"")
      expect(response.body).to include("<h1>Showing area of concern</h1>", ERB::Util.html_escape(area.name))
    end
  end
end
