require "rails_helper"
require Rails.root.join("db", "seeds", "data_paths")

RSpec.describe Seeds::CatalogContract do
  let(:contract) { described_class.document }

  it "exports the importer's types without database IDs or protected fields" do
    expect(contract.fetch("entities").keys).to match_array(Seeds::LibraryImporter::MODELS.keys)
    expect(contract.values_at("namespace", "catalog")).to eq(%w[MIC ASC])
    contract.fetch("entities").each_value do |entity|
      expect(entity.fetch("attributes").keys.grep(/_id\z/)).to be_empty
      expect(entity.fetch("attributes").keys & Seeds::LibraryImporter::PROTECTED_ATTRIBUTES).to be_empty
    end
  end

  it "lists allowed values and the nested lists the importer writes" do
    entities = contract.fetch("entities")
    expect(entities.dig("StanceEvidence", "attributes", "relation", "enum")).to eq(StanceEvidence::RELATIONS)
    expect(entities.dig("Candidacy", "attributes", "ballot_lines", "items", "required")).to eq([ "label" ])
    expect(entities.dig("Channel", "attributes")).not_to have_key("owner_type")
  end

  it "matches the contract published in the seed-data repository" do
    published = SeedDataPaths.primary_root.join("schemas/asc.contract.json")
    expect(published.read).to eq(JSON.pretty_generate(contract) + "\n")
  end
end
