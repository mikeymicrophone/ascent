require "rails_helper"
require "vips"

RSpec.describe MountainPreview do
  let(:snapshot) do
    {
      "voter_name" => "Renée O'Neil <&>", "race_name" => "Mayor of São Paulo & Town Council",
      "election_name" => "2026 General", "baseline" => 0,
      "candidates" => [ { "name" => "Dana Okafor", "rating" => 500, "off_ballot" => false } ]
    }
  end

  it "renders Unicode and escaped text with a single candidate at the rating boundaries" do
    [ 0, 500 ].each do |baseline|
      snapshot["baseline"] = baseline
      image = Vips::Image.new_from_buffer(described_class.new(snapshot).png, "")
      expect([ image.width, image.height ]).to eq([ 1200, 630 ])
    end
    svg = Nokogiri::XML(Views::PublicMountains::Preview.new(snapshot: snapshot).call)
    expect(svg.errors).to be_empty
    expect(svg.text).to include("Renée O'Neil <&>")
  end

  it "labels a crowded preview as partial and distinguishes unrated candidates from zero" do
    snapshot["candidates"] = 12.times.map { { "name" => "María Alejandra Fernández#{it}", "rating" => it.zero? ? nil : 0, "off_ballot" => true } }
    svg = Nokogiri::XML(Views::PublicMountains::Preview.new(snapshot: snapshot).call)
    expect(svg.text).to include("Top 10 shown", "Off ballot")
    expect(svg.css("circle").length).to eq(10)
    image = Vips::Image.new_from_buffer(described_class.new(snapshot).png, "")
    expect(image.width).to eq(1200)
    snapshot["candidates"] = snapshot["candidates"].first(2)
    expect(Nokogiri::XML(Views::PublicMountains::Preview.new(snapshot: snapshot).call).text).to include("Unrated")
  end

  it "keeps the SVG upload decoder blocked in the Rails process" do
    svg = Views::PublicMountains::Preview.new(snapshot: snapshot).call
    expect { Vips::Image.svgload_buffer(svg) }.to raise_error(Vips::Error, /blocked/)
    expect(described_class.new(snapshot).png).to start_with("\x89PNG".b)
    expect { Vips::Image.svgload_buffer(svg) }.to raise_error(Vips::Error, /blocked/)
  end

  it "keeps the snapshot order for equally rated candidates" do
    snapshot["candidates"] = [ "Amina", "Beatriz", "Chloé" ].map { { "name" => it, "rating" => 300, "off_ballot" => false } }
    labels = Nokogiri::XML(Views::PublicMountains::Preview.new(snapshot: snapshot).call).text
    expect(labels.index("Amina")).to be < labels.index("Beatriz")
    expect(labels.index("Beatriz")).to be < labels.index("Chloé")
  end

  it "preserves the mountain's candidate order when ratings differ" do
    snapshot["candidates"] = [ [ "Dana", 100 ], [ "Amina", 500 ], [ "Marisol", 280 ] ].map do |name, rating|
      { "name" => name, "rating" => rating, "off_ballot" => false }
    end
    labels = Nokogiri::XML(Views::PublicMountains::Preview.new(snapshot: snapshot).call).text
    expect(labels.index("Dana")).to be < labels.index("Amina")
    expect(labels.index("Amina")).to be < labels.index("Marisol")
  end
end
