require "rails_helper"

RSpec.describe Seeds::LibraryImporter do
  let(:manifest) { Rails.root.join("spec/fixtures/seed_library/kelles_2024.yml").to_s }
  let(:importer) { described_class.new }

  before { Year.create!(year: 2024, is_even_year: true, is_presidential_year: true) }

  def write_manifest(name, contents)
    path = Rails.root.join("tmp", "seed_library_spec", name)
    FileUtils.mkdir_p(path.dirname)
    path.write(contents)
    path.to_s
  end

  it "imports one candidacy with a ballot line and a party endorsement for each printed line" do
    report = importer.call([ manifest ])

    candidacy = Candidacy.find_by!(entity_code: "CANDIDACY-USA-NY-ASSEMBLY-AD_125-2024_GENERAL-KELLES_ANNA_NY_AD_125")
    expect(candidacy.person).to have_attributes(username: "kelles_anna_ny_ad_125", username_status: "provisional", email: nil)
    expect(candidacy.ballot_lines.map { |line| [ line.label, line.kind, line.party.entity_code ] }).to eq([
      [ "Democratic", "party", "PARTY-USA-NY-DEMOCRATIC" ],
      [ "Working Families", "party", "PARTY-USA-NY-WORKING_FAMILIES" ]
    ])
    expect(candidacy.endorsements.map { |endorsement| [ endorsement.kind, endorsement.endorser.name ] })
      .to contain_exactly([ "ballot_line", "Democratic" ], [ "ballot_line", "Working Families" ])
    expect(candidacy.ballot_labels).to eq("Democratic; Working Families")

    race = candidacy.race
    expect(race).to have_attributes(entity_code: "RACE-USA-NY-ASSEMBLY-AD_125-2024_GENERAL", certification_status: "certified")
    expect(race.election).to have_attributes(entity_code: "ELECTION-USA-NY-ASSEMBLY-AD_125-2024_GENERAL", year: Year.find_by!(year: 2024))
    expect(race.office).to have_attributes(seat_code: "AD_125", name: "State Representative - New York Assembly District 125")

    district = District.find_by!(entity_code: "DISTRICT-USA-NY-ASSEMBLY-AD_125")
    expect(district.jurisdiction.parent.jurisdictionable).to eq(State.find_by!(entity_code: "STATE-USA-NY"))
    expect(State.find_by!(code: "NY").jurisdiction.parent.jurisdictionable).to eq(Country.find_by!(code: "US"))

    expect(report[:created].size).to eq(11)
    expect(report[:ballot_lines_added].size).to eq(2)
    expect(EntityCode.where(catalog: "ASC").count).to eq(11)
    expect(EntityCode.find_by!(code: "PERSON-KELLES_ANNA_NY_AD_125").record).to eq(candidacy.person)
  end

  it "changes nothing when the same manifest is imported again" do
    importer.call([ manifest ])
    counts = -> { [ Candidacy, BallotLine, Endorsement, Party, Jurisdiction, EntityCode ].map(&:count) }

    expect { importer.call([ manifest ]) }.not_to change(&counts)
    expect(importer.report[:unchanged].size).to eq(11)
    expect(importer.report[:conflicts]).to be_empty
  end

  it "adopts uncoded records created by the reference seeders" do
    country = Country.create!(code: "US", name: "United States")
    position = Position.create!(title: "State Representative", branch: :legislative)

    importer.call([ manifest ])

    expect(country.reload.entity_code).to eq("COUNTRY-USA")
    expect(position.reload.entity_code).to eq("POSITION-STATE_REPRESENTATIVE")
    expect(Country.count).to eq(1)
  end

  it "reports a differing existing value instead of overwriting it" do
    importer.call([ manifest ])
    Race.find_by!(entity_code: "RACE-USA-NY-ASSEMBLY-AD_125-2024_GENERAL").update!(certification_status: "tentative")

    importer.call([ manifest ])

    expect(Race.find_by!(entity_code: "RACE-USA-NY-ASSEMBLY-AD_125-2024_GENERAL").certification_status).to eq("tentative")
    expect(importer.report[:conflicts]).to contain_exactly(
      a_hash_including(code: "RACE-USA-NY-ASSEMBLY-AD_125-2024_GENERAL",
        differences: { "certification_status" => { existing: "tentative", incoming: "certified" } })
    )
  end

  it "resolves a registered alias to the same record" do
    importer.call([ manifest ])
    aliased = write_manifest("alias.yml", <<~YAML)
      format: micharisma-seeds/v1
      namespace: MIC
      catalog: ASC
      records:
        - type: Person
          code: PERSON-KELLES_ANNA_NY_AD_125
          aliases: [PERSON-KELLES_ANNA]
    YAML

    importer.call([ aliased ])

    expect(importer.report[:aliases_added]).to eq([ "PERSON-KELLES_ANNA" ])
    expect(importer.resolve_code("Person", "MIC-ASC-PERSON-KELLES_ANNA")).to eq(Person.find_by!(username: "kelles_anna_ny_ad_125"))
  end

  it "writes nothing for a record until its dependencies exist" do
    district = write_manifest("a_district.yml", <<~YAML)
      format: micharisma-seeds/v1
      namespace: MIC
      catalog: ASC
      scope:
        state: STATE-USA-NY
      records:
        - type: District
          code: DISTRICT-USA-NY-ASSEMBLY-AD_125
          attributes:
            name: New York Assembly District 125
            kind: assembly district
    YAML
    state = write_manifest("b_state.yml", <<~YAML)
      format: micharisma-seeds/v1
      namespace: MIC
      catalog: ASC
      records:
        - type: Country
          code: COUNTRY-USA
          attributes: {code: US, name: United States}
        - type: State
          code: STATE-USA-NY
          attributes: {code: NY, name: New York}
          references: {country: COUNTRY-USA}
    YAML

    report = importer.call([ district, state ])

    expect(report[:created]).to eq(%w[COUNTRY-USA STATE-USA-NY DISTRICT-USA-NY-ASSEMBLY-AD_125])
    expect(report[:unchanged]).to be_empty
    expect(District.sole.jurisdiction.parent.jurisdictionable).to eq(State.sole)
  end

  it "rejects attributes that are not part of the catalog contract" do
    invalid = write_manifest("invalid.yml", <<~YAML)
      format: micharisma-seeds/v1
      namespace: MIC
      catalog: ASC
      records:
        - type: Candidacy
          code: CANDIDACY-EXAMPLE
          attributes:
            party_affiliation: Democratic
    YAML

    expect { importer.validate([ invalid ]) }.to raise_error(described_class::Error, /unsupported Candidacy attribute party_affiliation/)
  end

  it "refuses entity-sequence lookups until their recipes are installed" do
    sequenced = write_manifest("sequenced.yml", <<~YAML)
      format: micharisma-seeds/v1
      namespace: MIC
      catalog: ASC
      entity_sequence: "10_01"
      records:
        - type: Person
          code: PERSON-EXAMPLE
    YAML

    expect { importer.validate([ sequenced ]) }.to raise_error(StandardError, /sequence/i)
  end
end
