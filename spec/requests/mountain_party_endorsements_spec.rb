require "rails_helper"

RSpec.describe "Party endorsements on the mountain", type: :request do
  let(:race) { create(:race, :active) }
  let(:voter) { create(:voter) }
  let(:candidacy) { create(:candidacy, race: race, party_label: nil) }
  let(:state) { create(:state) }

  it "offers a hidden-by-default toggle with current parties below names in both views" do
    harbor = Party.create!(name: "Harbor Party", state: state)
    green = Party.create!(name: "Green Party", state: state)
    former = Party.create!(name: "Former Party", state: state)
    candidacy.ballot_lines.create!(party: harbor, label: "Harbor", kind: "party")
    create(:endorsement, candidacy: candidacy, endorser: harbor)
    create(:endorsement, candidacy: candidacy, endorser: green)
    create(:endorsement, :withdrawn, candidacy: candidacy, endorser: former)
    create(:endorsement, candidacy: candidacy, endorser: create(:organization, :union))
    candidacy.ballot_lines.create!(label: "Community petition", kind: "petition")
    sign_in voter

    get mountain_path(race)

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body)
    expect(page.at_css(".mountain-page")["data-party-endorsements"]).to eq("false")
    toggle = page.at_css("button[data-action='mountain-editor#togglePartyEndorsements']")
    expect(toggle.text).to eq("Party endorsements")
    expect(toggle["aria-pressed"]).to eq("false")
    expect(page.css(".candidate-info .column-name + .party-endorsements").map(&:text)).to eq([ "Harbor Party; Green Party" ])
    expect(page.css(".rating-row-name .rating-row-label + .party-endorsements").map(&:text)).to eq([ "Harbor Party; Green Party" ])
    expect(page.css(".rating-row-sub").map(&:text)).to include("Community petition")
    expect(page.css(".party-endorsements").text).not_to include("Former Party", "Harbor Workers Union")
  end

  it "leaves candidates without endorsements free of empty labels" do
    candidacy
    sign_in voter

    get mountain_path(race)

    expect(response).to have_http_status(:ok)
    expect(Nokogiri::HTML(response.body).css(".party-endorsements")).to be_empty
  end
end
