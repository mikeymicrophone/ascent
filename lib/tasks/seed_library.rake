namespace :seed_library do
  def seed_library_paths
    root = Pathname.new(ENV.fetch("SEED_LIBRARY_ROOT", Rails.root.join("db/seeds/ascent_seed_data/manifests").to_s))
    paths = Dir.glob(root.join("**/*.{yaml,yml,json}").to_s).sort
    raise "No seed manifests in #{root}" if paths.empty?

    paths
  end

  desc "Validate micharisma-seeds/v1 manifests for the Ascent catalog (SEED_LIBRARY_ROOT selects a folder)"
  task validate: :environment do
    puts Seeds::LibraryImporter.new.validate(seed_library_paths).to_json
  end

  desc "Import micharisma-seeds/v1 manifests, preserving existing values and reporting conflicts"
  task import: :environment do
    report = Seeds::LibraryImporter.new.call(seed_library_paths)
    puts report.transform_values(&:length).to_json
    report[:conflicts].each { |conflict| puts conflict.to_json }
  end
end
