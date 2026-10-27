require "rails_helper"

# Results show totals only, residents and visitors apart, from the first saved mountain.
RSpec.describe "Race results", type: :request do
  let(:race) { create(:race, :active) }
  let(:okafor) { create(:candidacy, race: race, person: create(:person, first_name: "Dana", middle_name: nil, last_name: "Okafor")) }
  let(:lindqvist) { create(:candidacy, race: race, person: create(:person, first_name: "Theo", middle_name: nil, last_name: "Lindqvist")) }

  def mountain!(ratings, counted_as: "resident")
    voter = create(:voter)
    VoterRaceBaseline.create!(voter: voter, race: race, baseline: 250, counted_as: counted_as)
    ratings.each { |candidacy, rating| Rating.create!(voter: voter, candidacy: candidacy, rating: rating) }
  end

  it "invites the first mountain when there are none, and shows results from the first one" do
    get race_results_path(race)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No mountains yet", "Build your mountain")

    mountain!({ okafor => 400 })
    get race_results_path(race)

    expect(response.body).to include("Approval tally", "Dana Okafor", "100%")
  end

  it "shows residents' approval beside first choice, and keeps visitors apart" do
    6.times { mountain!({ okafor => 300, lindqvist => 450 }) }
    4.times { mountain!({ okafor => 400, lindqvist => 100 }) }
    2.times { mountain!({ lindqvist => 500 }, counted_as: "visitor") }

    get race_results_path(race)

    expect(response.body).to include("Approval tally", "Dana Okafor", "100%", "60%", "Totals only.")
    expect(response.body).to include("Count only each mountain&#39;s highest-rated candidate and Lindqvist leads.")

    get race_results_path(race, group: "visitor")

    # The two visitors approve only Lindqvist; residents' 100% for Okafor stays out of their tally.
    expect(response.body).to match(/Theo Lindqvist<\/td><td class="numeric strong">100%/)
    expect(response.body).to match(/Dana Okafor<\/td><td class="numeric strong">0%/)
  end
end
