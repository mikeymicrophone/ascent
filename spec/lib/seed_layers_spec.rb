require "rails_helper"
require Rails.root.join("db", "seeds", "seed_layers")

RSpec.describe SeedLayers do
  describe ".seed_reference!" do
    before do
      described_class.send(:load_seeders!)
    end

    it "loads only the factual reference seeders" do
      expect(CountrySeeder).to receive(:seed).with(SeedDataPaths.file("countries.yml"))
      expect(StateSeeder).to receive(:seed).with([
        SeedDataPaths.file("us_states.yml"),
        SeedDataPaths.file("canadian_provinces.yml")
      ])
      expect(CitySeeder).to receive(:seed)
      expect(PositionSeeder).to receive(:seed)
      expect(YearSeeder).to receive(:seed)
      expect(GubernatorialRaceSeeder).to receive(:seed)
      expect(VoterSeeder).not_to receive(:seed)
      expect(ElectionSeeder).not_to receive(:seed)

      described_class.seed_reference!
    end
  end

  describe ".seed_simulated!" do
    before do
      described_class.send(:load_seeders!)
      allow(described_class).to receive(:seed_reference!)
    end

    it "adds the simulated experience after the reference layer" do
      SeedLayers::SIMULATED_SEEDER_FILES.each do |filename|
        constant_name = filename.delete_suffix("_seeder").camelize.concat("Seeder")
        expect(constant_name.constantize).to receive(:seed)
      end

      described_class.seed_simulated!

      expect(described_class).to have_received(:seed_reference!)
    end
  end
end
