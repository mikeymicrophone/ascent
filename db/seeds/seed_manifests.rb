# Imports the coded reference library: the micharisma-seeds/v1 manifests the ballot converter writes.
module SeedManifests
  module_function

  # Foundation files first, so places, parties, and positions exist before the contests that use them.
  def paths(root = SeedDataPaths.primary_root.join("manifests"))
    Dir.glob(Pathname.new(root).join("**", "*.{yml,yaml,json}").to_s)
       .sort_by { |path| [ File.basename(path, ".*") == "foundation" ? 0 : 1, path ] }
  end

  def seed(paths = self.paths)
    report = Seeds::LibraryImporter.new.call(paths)
    puts "Imported #{paths.size} manifests: #{report.transform_values(&:size)}"
    report
  end
end
