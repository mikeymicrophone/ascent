require "rails_helper"

RSpec.describe "Profile media", type: :request do
  let(:person) do
    create(:person, first_name: "Marisol", middle_name: nil, last_name: "Vega", portrait_url: "https://images.example.org/marisol.jpg",
      portrait_credit: "Riverside Studio", portrait_source_url: "https://example.org/portraits/marisol")
  end
  let(:candidacy) { create(:candidacy, person: person) }

  it "shows the same credited portrait on the person and candidacy pages" do
    [ person_path(person), candidacy_path(candidacy) ].each do |path|
      get path

      expect(response).to have_http_status(:ok)
      page = Nokogiri::HTML(response.body)
      expect(page.at_css(".profile-portrait-image")["src"]).to eq(person.portrait_url)
      expect(page.at_css(".profile-portrait-image")["alt"]).to eq("Portrait of Marisol Vega")
      expect(page.at_css(".profile-portrait-credit a")["href"]).to eq(person.portrait_source_url)
      expect(page.at_css(".profile-portrait-credit").text).to eq("Riverside Studio")
    end
  end

  it "separates personal and campaign channels and excludes another campaign's media" do
    earlier = create(:candidacy, person: person)
    personal = create(:channel, owner: person, official: true, platform: "bluesky", url: "https://bsky.app/profile/marisol.example")
    campaign = create(:channel, owner: candidacy, official: true, platform: "website", url: "https://example.org/marisol")
    old_channel = create(:channel, owner: earlier, official: true, platform: "website", url: "https://example.org/earlier")
    create(:communication, channel: personal, title: "A neighborhood walk", kind: "post")
    create(:communication, channel: campaign, title: "Current campaign priorities", kind: "platform")
    create(:communication, channel: old_channel, title: "Earlier campaign launch", kind: "platform")

    get candidacy_path(candidacy)

    expect(response.body).to include("Personal", "Campaign ·", "A neighborhood walk", "Current campaign priorities")
    expect(response.body).not_to include("Earlier campaign launch", old_channel.url)

    get person_path(person)

    expect(response.body).to include("Earlier campaign launch", old_channel.url)
  end

  it "keeps a photo source accessible when no credit text was supplied" do
    person.update!(portrait_credit: nil)

    get person_path(person)

    source = Nokogiri::HTML(response.body).at_css(".profile-portrait-credit a")
    expect(source["href"]).to eq(person.portrait_source_url)
    expect(source.text).to eq("Photo source")
  end

  it "loads provider players only after a play action, while retaining source links" do
    video = create(:communication, title: "Housing town hall", url: "https://youtu.be/M7lc1UVf-VE")
    video.communication_features.create!(candidacy: candidacy)

    get candidacy_path(candidacy)

    page = Nokogiri::HTML(response.body)
    expect(page.at_css("button[data-action='media-player#play']")["aria-label"]).to eq("Play Housing town hall")
    expect(page.at_css("template iframe")["src"]).to eq("https://www.youtube-nocookie.com/embed/M7lc1UVf-VE?autoplay=1&playsinline=1")
    expect(page.css("iframe").reject { it.ancestors("template").any? }).to be_empty
    expect(page.at_css(%(a[href="#{video.url}"])).text).to include("Open original")

    get person_path(person)
    expect(response.body).to include("Housing town hall")
  end

  it "provides native playback for direct videos and a fallback for removed or unsupported sources" do
    file = create(:communication, url: "https://media.example.org/intro.mp4", title: "Introduction")
    removed = create(:communication, url: "https://vimeo.com/123456", availability: "removed", archived_url: "https://archive.example.org/video")
    unsupported = create(:communication, url: "https://example.org/interview", title: "Local radio interview")
    [ file, removed, unsupported ].each { it.communication_features.create!(candidacy: candidacy) }

    get candidacy_path(candidacy)

    page = Nokogiri::HTML(response.body)
    expect(page.css("video").map { it["src"] }).to eq([ file.url ])
    expect(page.at_css("video[controls]")).to be_present
    expect(page.at_css("video")["autoplay"]).to be_nil
    expect(page.css("iframe")).to be_empty
    expect(response.body).to include("no longer available", "Archived copy", "Local radio interview")
  end

  it "lets an admin edit portrait details and rejects executable URLs" do
    sign_in create(:voter, admin: true)

    patch person_path(person), params: { person: { portrait_url: "https://images.example.org/new.jpg", portrait_credit: "City Studio" } }
    expect(response).to redirect_to(person)
    expect(person.reload.portrait_credit).to eq("City Studio")

    patch person_path(person), params: { person: { portrait_url: "javascript:alert(1)" } }
    expect(response).to have_http_status(:unprocessable_content)
    expect(person.reload.portrait_url).to eq("https://images.example.org/new.jpg")
  end
end
