require "rails_helper"
require Rails.root.join("db", "seeds", "data_paths")
require Rails.root.join("db", "seeds", "ballot_line_seeder")

RSpec.describe BallotLineSeeder do
  let(:paths) { SeedDataPaths.glob(*described_class::DATA_GLOB).sort }

  it "loads every YAML file under the New York ballot directory" do
    expect(paths.size).to be > 1
    expect(paths.map { |path| File.dirname(path) }.uniq.size).to be > 1
    expect(paths).to all(end_with(".yml"))

    rows = described_class.seed(paths)

    expect(rows.size).to eq(1851)
    expect(rows).to all(include(*described_class::REQUIRED_KEYS))
    expect(rows.map { |row| row.fetch("state") }.uniq).to eq(["NY"])
    expect(rows.map { |row| row.fetch("election_date") }.uniq).to eq(["2026-11-03"])
  end
end
