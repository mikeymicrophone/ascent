require "fileutils"
require Rails.root.join("db/seeds/data_paths")

namespace :seed_data do
  desc "Seed only the factual reference layer used by normal app setup"
  task reference: :environment do
    require Rails.root.join("db", "seeds", "seed_layers")
    SeedLayers.seed_reference!
  end

  desc "Seed the fictitious demo layer after the factual reference layer"
  task simulated: :environment do
    require Rails.root.join("db", "seeds", "seed_layers")
    SeedLayers.seed_simulated!
  end

  desc "Copy legacy seed YAML into the ascent_seed_data submodule working tree"
  task copy_legacy_to_submodule: :environment do
    source_root = SeedDataPaths.legacy_root
    target_root = SeedDataPaths.primary_root

    unless source_root.exist?
      abort "Legacy seed data directory not found at #{source_root}"
    end

    if source_root == target_root
      abort "Primary seed data path still points at the legacy directory"
    end

    FileUtils.mkdir_p(target_root)

    copied_files = Dir.glob(source_root.join("**", "*"), File::FNM_DOTMATCH).filter_map do |path|
      next if [".", ".."].include?(File.basename(path))
      next if File.directory?(path)

      relative_path = Pathname(path).relative_path_from(source_root)
      destination = target_root.join(relative_path)
      FileUtils.mkdir_p(destination.dirname)
      FileUtils.cp(path, destination)
      relative_path.to_s
    end

    puts "Copied #{copied_files.count} seed data files to #{target_root}"
    copied_files.sort.each { |file| puts "  - #{file}" }
  end
end
