require "rails_helper"

# A person's page lists every candidacy, latest first, and leads to the latest one.
RSpec.describe "Person page", type: :request do
  let(:person) { create(:person, first_name: "Marisol", middle_name: nil, last_name: "Okafor", bio: nil) }
  let!(:earlier) do
    create(:candidacy, person: person, status: "active", race: create(:race, :completed, election: create(:election, :completed, name: "Calder Primary 2024", election_date: Date.new(2024, 6, 4))))
  end
  let!(:latest) do
    create(:candidacy, person: person, status: "active", party_label: "Harbor Party",
      race: create(:race, :active, election: create(:election, :active, name: "Calder General 2026", election_date: Date.new(2026, 11, 3))))
  end

  it "lists candidacies latest first and links to the latest" do
    get person_path(person)

    page = Nokogiri::HTML(response.body)
    expect(response).to have_http_status(:ok)
    expect(page.css(".breadcrumb a").map(&:text)).to eq([ "People" ])
    expect(page.at_css("h1").text).to eq("Marisol Okafor")
    expect(page.css("#person-candidacies .list-row-meta").map(&:text).map { it.split(" · ").first }).to eq([ "Calder General 2026", "Calder Primary 2024" ])
    expect(page.at_css(".page-header .pill-button")["href"]).to eq(candidacy_path(latest))
    expect(response.body).to include("1 earlier candidacy below.", "Harbor Party")
  end

  it "links their official channels, and only official ones" do
    Channel.create!(owner: person, platform: "bluesky", handle: "marisolokafor", official: true, url: "https://bsky.app/profile/marisolokafor")
    Channel.create!(owner: person, platform: "x", handle: "okafor_fan", official: false)

    get person_path(person)

    page = Nokogiri::HTML(response.body)
    expect(page.at_css(%(a[href="https://bsky.app/profile/marisolokafor"])).text).to eq("marisolokafor · Bluesky")
    expect(response.body).not_to include("okafor_fan")
  end

  it "finds people by name" do
    get people_path, params: { q: "marisol ok" }

    expect(response.body).to include(%(id="list_item_person_#{person.id}"))

    get people_path, params: { q: "Nobody" }

    expect(response.body).not_to include(%(id="list_item_person_#{person.id}"))
    expect(response.body).to include("No people match")
  end
end
