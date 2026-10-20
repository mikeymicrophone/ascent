class BallotLineSeeder
  DATA_GLOB = ["races", "2026", "new_york", "**", "*.yml"].freeze
  REQUIRED_KEYS = %w[
    election_date
    state
    office
    district
    office_level
    candidate_name
    party
    incumbent
    status
    source_url
    retrieved_on
  ].freeze

  def self.seed(paths = SeedDataPaths.glob(*DATA_GLOB))
    rows = paths.sort.flat_map { |path| rows_from(path) }

    puts "Loaded #{rows.size} ballot lines from #{paths.size} files"
    rows
  end

  def self.rows_from(path)
    rows = YAML.load_file(path)
    raise "#{path} must contain a list of ballot lines" unless rows.is_a?(Array)

    rows.each do |row|
      missing = REQUIRED_KEYS.reject { |key| row.key?(key) }
      raise "#{path} is missing #{missing.join(", ")}" if missing.any?
    end

    rows
  end
end
