require "rails_helper"

RSpec.describe "Importing communications and stance evidence" do
  let(:town_hall) { Rails.root.join("spec/fixtures/seed_library/communications/a_town_hall.yml").to_s }
  let(:debate_clip) { Rails.root.join("spec/fixtures/seed_library/communications/b_debate_clip.yml").to_s }
  let(:stance_code) { "STANCE-USA-NY-EXAMPLE-ED_1-2026_GENERAL-EXAMPLE_AVERY_NY_ED_1-ENVIRONMENT-ENERGY_INTENSIVE_MINING-TIME_LIMITED_PERMIT_MORATORIUM" }

  before { Year.create!(year: 2026, is_even_year: true, is_presidential_year: false) }

  it "lets a second contribution add evidence to an existing stance" do
    Seeds::LibraryImporter.new.call([ town_hall ])
    report = Seeds::LibraryImporter.new.call([ debate_clip ])

    expect(report[:conflicts]).to be_empty
    stance = Stance.find_by!(entity_code: stance_code)
    expect(stance.stance_evidences.map { |evidence| [ evidence.relation, evidence.timestamp ] })
      .to contain_exactly([ "states", "1:42" ], [ "clarifies", "25:05" ])
    expect(stance.communications.map(&:kind)).to contain_exactly("video", "debate")

    channel = Channel.find_by!(entity_code: "CHANNEL-WEBSITE-AVERYEXAMPLE_EXAMPLE_COM")
    expect(channel).to have_attributes(official: true, owner: Person.find_by!(username: "example_avery_ny_ed_1"))
    expect(stance.candidacy.featured_communications.count).to eq(2)
  end

  it "imports both contributions together and re-imports without change" do
    importer = Seeds::LibraryImporter.new
    importer.call([ town_hall, debate_clip ])
    counts = -> { [ Channel, Communication, CommunicationFeature, Stance, StanceEvidence, EntityCode ].map(&:count) }

    expect { importer.call([ town_hall, debate_clip ]) }.not_to change(&counts)
    expect(importer.report[:conflicts]).to be_empty
    expect(importer.report[:features_added]).to be_empty
  end

  it "rejects a channel owner that is not a person, party, or candidacy" do
    path = Rails.root.join("tmp", "communications_import_spec", "bad_owner.yml")
    FileUtils.mkdir_p(path.dirname)
    path.write(File.read(town_hall).sub("references: {owner: PERSON-EXAMPLE_AVERY_NY_ED_1}", "references: {owner: STATE-USA-NY}"))

    expect { Seeds::LibraryImporter.new.call([ path.to_s ]) }.to raise_error(Seeds::LibraryImporter::Error, /not a Person, Party, Candidacy code/)
  end
end
