require "rails_helper"
require Rails.root.join("db", "seeds", "data_paths")
require Rails.root.join("db", "seeds", "seed_jurisdictions")
require Rails.root.join("db", "seeds", "gubernatorial_race_seeder")

RSpec.describe GubernatorialRaceSeeder do
  let(:paths) { SeedDataPaths.glob(*described_class::DATA_GLOB).sort }

  it "has one sourced general-election record for each 2026 state gubernatorial race" do
    expect(paths).to have_attributes(length: 36)

    paths.each do |path|
      race = YAML.load_file(path).fetch("race")

      expect(race).to include(
        "country_code" => "US",
        "general_election_date" => "2026-11-03",
        "status" => "upcoming"
      )
      expect(race.fetch("source").fetch("url")).to start_with("https://")
    end
  end

  it "creates a source-backed governor race in each state's general election, without candidates" do
    country = Country.find_or_create_by!(code: "US") { |record| record.name = "United States" }
    Year.create!(year: 2026, is_even_year: true, is_presidential_year: false)
    Position.find_or_create_by!(title: "Governor") do |record|
      record.description = "State executive"
      record.branch = :executive
      record.term_length_years = 4
    end

    paths.each do |path|
      race = YAML.load_file(path).fetch("race")
      State.find_or_create_by!(country: country, code: race.fetch("state_code")) do |record|
        record.name = race.fetch("state_code")
      end
    end

    described_class.seed(paths)

    races = Race.joins(office: :position).where(positions: { title: "Governor" })
    expect(races.count).to eq(36)
    expect(races).to all(have_attributes(status: "upcoming"))
    expect(races.map(&:election)).to all(have_attributes(is_mock: false, status: "upcoming", kind: "general", election_date: Date.new(2026, 11, 3)))
    expect(races.map { |race| race.election.jurisdiction.jurisdictionable }).to all(be_a(State))
    expect(races.map { |race| race.candidacies.count }).to all(eq(0))
  end
end
