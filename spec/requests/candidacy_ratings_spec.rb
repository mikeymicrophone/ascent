require 'rails_helper'

# A candidacy's page shows how voters rated the candidate only in total, so no visitor can learn how
# any one voter rated them. An approval counts against each voter's own baseline in the race.
RSpec.describe "Ratings on a candidacy", type: :request do
  let(:race) { create(:race, :active) }
  let(:candidacy) { create(:candidacy, race: race, status: "active") }
  let(:priya) { create(:voter, first_name: "Priya", last_name: "Raman") }
  let(:tomas) { create(:voter, first_name: "Tomas", last_name: "Lind") }
  let(:ada) { create(:voter, first_name: "Ada", last_name: "Okoye") }

  before do
    Rating.create!(voter: priya, candidacy: candidacy, rating: 420)
    Rating.create!(voter: tomas, candidacy: candidacy, rating: 180)
    Rating.create!(voter: ada, candidacy: candidacy, rating: 303)
    VoterRaceBaseline.create!(voter: priya, race: race, baseline: 250)
    VoterRaceBaseline.create!(voter: tomas, race: race, baseline: 250)
  end

  it "shows how many voters rated and approve the candidate, never who or how" do
    get candidacy_path(candidacy)

    expect(response).to have_http_status(:ok)
    page = Nokogiri::HTML(response.body).at_css(".candidacy-ratings")
    expect(page.css(".stat-item").map { [ it.at_css(".stat-label").text, it.at_css(".stat-value").text ] })
      .to eq([ [ "voters rated", "3" ], [ "average rating", "301.0" ], [ "approve", "1" ] ])
    expect(page.text).not_to include("420", "180", "303")
    expect(response.body).not_to include("Priya Raman", "Tomas Lind", "Ada Okoye")
  end

  it "keeps voters' names off the candidacies list too" do
    get candidacies_path

    expect(response.body).to include("voters rated")
    expect(response.body).not_to include("Priya Raman", "Tomas Lind", "Ada Okoye")
  end

  it "says when nobody has rated the candidate yet" do
    Rating.where(candidacy: candidacy).delete_all

    get candidacy_path(candidacy)

    expect(response.body).to include("No voter has rated this candidate yet.")
  end

  it "counts an approval of a primary candidate only from voters who include primary candidates" do
    from_primary = create(:candidacy, race: race, status: "active", participation: "off_ballot", primary_candidacy: create(:candidacy))
    Rating.create!(voter: priya, candidacy: from_primary, rating: 400)

    expect(from_primary.approvals_count).to eq(0)

    priya.include_primary_candidates!(race, true)

    expect(from_primary.approvals_count).to eq(1)
    expect(race.aggregate_votes[from_primary]).to eq(1)
  end
end
