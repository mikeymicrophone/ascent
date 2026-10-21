require "rails_helper"
require Rails.root.join("db", "seeds", "data_paths")
require Rails.root.join("db", "seeds", "seed_jurisdictions")
require Rails.root.join("db", "seeds", "position_seeder")
require Rails.root.join("db", "seeds", "ballot_line_seeder")

RSpec.describe BallotLineSeeder do
  let(:paths) { SeedDataPaths.glob(*described_class::DATA_GLOB).sort }

  it "reads every 2026 state ballot file with the required columns" do
    expect(paths.map { |path| path.split("/races/2026/").last.split("/").first }.uniq)
      .to contain_exactly("connecticut", "florida", "massachusetts", "new_york", "virginia")

    rows = paths.flat_map { |path| described_class.rows_from(path) }

    expect(rows.size).to eq(7719)
    expect(rows).to all(include(*described_class::REQUIRED_KEYS))
    expect(rows.map { |row| row.fetch("state") }.uniq).to contain_exactly("CT", "FL", "MA", "NY", "VA")
    expect(rows.map { |row| row.fetch("election_date") }.uniq).to eq([ "2026-11-03" ])
  end

  it "maps every federal and state office title to a shared position" do
    titles = paths.reject { |path| path.include?("/local/") }
                  .flat_map { |path| described_class.rows_from(path) }
                  .map { |row| row.fetch("office") }.uniq

    expect(titles - described_class::STATE_LEVEL_OFFICES.keys).to be_empty
  end

  describe ".name_parts" do
    {
      "Christopher J. Gallant" => { first_name: "Christopher", middle_name: "J.", last_name: "Gallant" },
      "Angelo J. Puppolo, Jr." => { first_name: "Angelo", middle_name: "J.", last_name: "Puppolo, Jr." },
      "Henry White Jr." => { first_name: "Henry", middle_name: nil, last_name: "White Jr." },
      "Charles E. \"Chuck\" Tiernan, III" => { first_name: "Charles", middle_name: "E. \"Chuck\"", last_name: "Tiernan, III" },
      "Healey" => { first_name: nil, middle_name: nil, last_name: "Healey" }
    }.each do |printed_name, parts|
      it "splits #{printed_name.inspect} so the full name reads as printed" do
        expect(described_class.name_parts(printed_name)).to eq(parts)
        expect(Person.new(parts).full_name).to eq(printed_name)
      end
    end
  end

  describe ".seed" do
    let(:sample) do
      %w[
        new_york/federal/representative_in_congress.yml
        massachusetts/state/governor.yml
        florida/state/district_court_of_appeal.yml
        florida/local/seminole_county.yml
        virginia/local/multi_county.yml
      ].map { |file| SeedDataPaths.file("races", "2026", file).to_s }
    end

    before do
      united_states = Country.create!(name: "United States", code: "US")
      SeedJurisdictions.ensure(united_states)
      { "NY" => "New York", "MA" => "Massachusetts", "FL" => "Florida", "VA" => "Virginia" }.each do |code, name|
        SeedJurisdictions.ensure(State.create!(country: united_states, code: code, name: name), parent: united_states.jurisdiction)
      end
      Year.create!(year: 2026, is_even_year: true, is_presidential_year: false)
      PositionSeeder.seed
    end

    it "builds districts, elections, races, and one candidacy per person per race" do
      described_class.seed(sample)

      district = District.find_by!(name: "New York Congressional District 1")
      race = Race.joins(:office).find_by!(offices: { jurisdiction_id: district.jurisdiction.id })
      expect(race.election).to have_attributes(name: "New York Congressional District 1 General Election 2026", kind: "general", is_mock: false)
      expect(race.office.position.title).to eq("Representative")
      lalota = race.candidacies.joins(:person).find_by!(people: { last_name: "Lalota" })
      expect(lalota.party_affiliation).to eq("Conservative; Republican")
      expect(race.description).to include("Vote for: 1.", "Source status: certified.", "Retrieved: 2026-10-01.")

      healey = Person.find_by!(last_name: "Healey")
      expect(healey).to have_attributes(first_name: nil, email: nil)
      expect(healey.candidacies.sole.office.jurisdiction.jurisdictionable).to eq(State.find_by!(code: "MA"))

      retention_races = Race.joins(office: :position).where(positions: { title: "Appellate Judge" })
      expect(retention_races.count).to eq(22)
      expect(retention_races.map { |retention| retention.candidacies.count }).to all(eq(1))
      expect(retention_races.map { |retention| retention.office.notes }).to all(start_with("Retention of "))

      sanford = Municipality.find_by!(name: "Sanford")
      expect(sanford.county.name).to eq("Seminole County")
      expect(sanford.jurisdiction.parent).to eq(sanford.county.jurisdiction)
      expect(sanford.offices.count).to eq(Race.joins(:office).where(offices: { jurisdiction_id: sanford.jurisdiction.id }).count)

      pamplin = District.find_by!(name: "Virginia Mayor - Pamplin City (Appomattox County, Prince Edward County)")
      expect(pamplin.jurisdiction.parent).to eq(State.find_by!(code: "VA").jurisdiction)
    end

    it "leaves the records unchanged when seeded again" do
      described_class.seed(sample)
      counts = -> { [ Jurisdiction.count, Office.count, Election.count, Race.count, Person.count, Candidacy.count ] }

      expect { described_class.seed(sample) }.not_to change(&counts)
    end
  end
end
