require "rails_helper"

# A voter's history of where they've lived: listed newest first, added by searching for a town and
# giving dates and districts, and removable, except a current residence, which the voter moves out of.
RSpec.describe "Past residences", type: :request do
  include_context "Port Merritt ballot"

  before { sign_in voter }

  it "lists the current residence and finds towns to add" do
    get past_residences_path(q: "Port Mer")

    expect(response.body).to include("Where you&#39;ve lived", "Port Merritt Ward 4", "– now", "Congressional District 7", "I lived here")
  end

  it "adds a past residence with its dates and districts" do
    post past_residences_path, params: { jurisdiction_id: port_merritt.id, started_on: "2012-09-01", ended_on: "2016-05-31",
      congressional_district_id: congressional_7.id }

    expect(response).to redirect_to(past_residences_path)
    expect(voter.residences.past.sole).to have_attributes(jurisdiction: port_merritt, started_on: Date.new(2012, 9, 1), congressional_district: congressional_7)
  end

  it "asks again when the dates are missing or backwards" do
    post past_residences_path, params: { jurisdiction_id: port_merritt.id, started_on: "2016-01-01", ended_on: "2012-01-01" }

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include("must be on or after the date you moved in")
  end

  it "removes a past residence but never the current one or someone else's" do
    past = voter.add_past_residence!(port_merritt, started_on: Date.new(2012, 1, 1), ended_on: Date.new(2014, 1, 1))
    neighbor_past = create(:voter).add_past_residence!(port_merritt, started_on: Date.new(2012, 1, 1), ended_on: Date.new(2014, 1, 1))

    expect { delete past_residence_path(residence) }.not_to change(Residence, :count)
    expect { delete past_residence_path(neighbor_past) }.not_to change(Residence, :count)
    expect(response).to have_http_status(:not_found)
    expect { delete past_residence_path(past) }.to change(Residence, :count).by(-1)
  end

  it "moves the voter out of a place they live now, keeping it in their history" do
    get past_residences_path
    expect(response.body).to include("Moved out", "Add another place you live")

    patch move_out_past_residence_path(residence)

    expect(response).to redirect_to(past_residences_path)
    expect(residence.reload).to have_attributes(ended_on: Date.current, status: "moved")
    expect(voter.current_residences).to be_empty
  end

  it "won't move a voter out of a past residence or someone else's" do
    past = voter.add_past_residence!(port_merritt, started_on: Date.new(2012, 1, 1), ended_on: Date.new(2014, 1, 1))
    neighbor = create(:voter).claim_residence!(port_merritt)

    patch move_out_past_residence_path(past)
    expect(past.reload.ended_on).to eq(Date.new(2014, 1, 1))
    patch move_out_past_residence_path(neighbor)
    expect(response).to have_http_status(:not_found)
    expect(neighbor.reload).to be_current
  end
end
