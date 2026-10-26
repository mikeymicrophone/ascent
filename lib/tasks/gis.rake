namespace :gis do
  desc "Import TIGER/Line boundaries from shapefiles or GeoJSON: bin/rails 'gis:import_tiger[../tiger2024/**/*.shp,2024]' " \
       "(a path or glob; DRY_RUN=1 reports matches without writing)"
  task :import_tiger, [ :paths, :vintage ] => :environment do |_task, args|
    paths = Dir.glob(args.fetch(:paths))
    abort "No files match #{args[:paths]}" if paths.empty?

    importer = Seeds::TigerBoundaryImporter.new(vintage: args.fetch(:vintage), dry_run: ENV["DRY_RUN"] == "1")
    report = importer.import_all(paths)

    puts "#{"Dry run: " if ENV["DRY_RUN"] == "1"}#{paths.size} file(s), vintage #{importer.vintage}"
    %i[matched created written released skipped placed_elsewhere unmatched_count ambiguous_count invalid_count].each { puts "  #{it}: #{report[it]}" }
    %i[unmatched ambiguous invalid].each do |key|
      next if report[key].empty?

      puts "#{key.to_s.capitalize} (first #{report[key].size}):"
      report[key].each { puts "  #{it}" }
    end
  end

  desc "Check that voters can be placed everywhere: a point in every county and a set of landmarks"
  task check_residences: :environment do
    check = Seeds::BoundaryCheck.new.run

    puts "#{check.counties_checked} counties checked; #{check.in_water.size} of their points fell in water"
    puts "Towns found: #{check.town_kinds.map { |kind, count| "#{kind} #{count}" }.join(", ")}"
    check.problems.each { |key, list| puts "#{key} (#{list.size}):", list.first(25).map { "  #{it}" } }
    abort "Residence check failed" unless check.ok?

    puts "All residence checks passed"
  end
end
