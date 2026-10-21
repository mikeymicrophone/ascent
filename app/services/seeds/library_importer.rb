require Rails.root.join("lib/micharisma_seeders/lib/micharisma_seeders").to_s

module Seeds
  # Imports micharisma-seeds/v1 manifests for the Ascent (ASC) catalog, ported from AthleteAce.
  # Missing records are created, existing values are preserved and their differences reported,
  # and every preferred code and alias is registered in EntityCode.
  class LibraryImporter
    class Error < StandardError; end
    class MissingReference < Error; end

    MODELS = {
      "Country" => Country, "State" => State, "County" => County, "Municipality" => Municipality,
      "District" => District, "Party" => Party, "Position" => Position, "Office" => Office,
      "Election" => Election, "Race" => Race, "Person" => Person, "Candidacy" => Candidacy
    }.freeze
    JURISDICTION_OWNERS = %w[Country State County Municipality District].freeze
    SCOPE_ASSOCIATIONS = {
      "State" => %w[country], "County" => %w[state], "Municipality" => %w[state county],
      "Party" => %w[state], "Office" => %w[position jurisdiction], "Election" => %w[jurisdiction year],
      "Race" => %w[election office], "Candidacy" => %w[race person]
    }.freeze
    # Keys that identify an uncoded record created by another seeder, so it can adopt its code.
    NATURAL_KEYS = {
      Country => %w[code], State => %w[country code], County => %w[state name],
      Municipality => %w[state name], District => %w[name], Party => %w[state name],
      Position => %w[title], Person => %w[username], Office => %w[position jurisdiction seat_code],
      Election => %w[jurisdiction election_date kind], Race => %w[election office], Candidacy => %w[race person]
    }.freeze
    BLANK_NATURAL_KEYS = { Office => %w[seat_code] }.freeze
    NESTED_ATTRIBUTES = { "Candidacy" => %w[ballot_lines] }.freeze
    BALLOT_LINE_KEYS = %w[label kind party].freeze
    PROTECTED_ATTRIBUTES = %w[id entity_code created_at updated_at].freeze
    EMPTY_REPORT = { created: [], unchanged: [], conflicts: [], aliases_added: [], ballot_lines_added: [] }.freeze

    attr_reader :report

    def initialize(namespace: "MIC", catalog: "ASC")
      @namespace, @catalog = namespace, catalog
      @report = empty_report
    end

    def read(paths)
      reader = MICharismaSeeders::Reader.new
      paths.flat_map { |path| reader.read(path) }
    end

    # A read-only preflight of the envelope, types, attributes, and code collisions.
    def validate(paths)
      records = read(paths)
      validate_records!(records)
      { records: records.length, codes: @reference_types.length, files: paths.length }
    end

    def call(paths)
      @report = empty_report
      records = read(paths)
      validate_records!(records)
      ApplicationRecord.transaction do
        load_bindings
        pending = records
        until pending.empty?
          deferred = []
          reasons = []
          pending.each do |record|
            import_record(record)
          rescue MissingReference => e
            deferred << record
            reasons << e.message
          end
          raise Error, "Unresolved seed dependencies:\n#{reasons.uniq.join("\n")}" if deferred.length == pending.length

          pending = deferred
        end
      end
      report
    rescue StandardError
      @report = empty_report
      raise
    ensure
      @bindings = @records = nil
    end

    def resolve_code(type, code)
      model = MODELS.fetch(type) { raise Error, "Unsupported entity type #{type}" }
      binding = binding_for(local_code(code))
      if binding
        raise Error, "#{code} identifies #{binding.record_type}, not #{type}" unless binding.record_type == type

        target = cached_record(binding.canonical_code) { binding.resolved_record || model.find_by(entity_code: binding.canonical_code) }
        return target if target
      end
      model.find_by(entity_code: local_code(code))
    end

    private

    def empty_report
      EMPTY_REPORT.transform_values(&:dup)
    end

    # During an import every binding in the catalog is held in memory, along with the records
    # it has resolved, so a manifest's thousands of references do not each query the database.
    def load_bindings
      @bindings = EntityCode.where(namespace: @namespace, catalog: @catalog).index_by(&:code)
      @records = {}
    end

    def binding_for(code)
      return @bindings[code] if @bindings

      EntityCode.find_by(namespace: @namespace, catalog: @catalog, code: code)
    end

    def cached_record(canonical_code)
      return yield unless @records

      @records[canonical_code] ||= yield
    end

    def validate_records!(records)
      declared = {}
      parents = {}
      root = lambda do |code|
        parents[code] ||= code
        parents[code] = root.call(parents[code]) unless parents[code] == code
        parents[code]
      end
      records.each do |record|
        validate_record!(record)
        ([ record.code ] + record.aliases).each do |code|
          raise Error, "#{record.location}: #{code} identifies multiple types" if declared[code] && declared[code].type != record.type

          declared[code] ||= record
          parents[root.call(code)] = root.call(record.code)
        end
      end
      @reference_types = declared.transform_values(&:type)
      records.group_by { |record| root.call(record.code) }.each_value do |definitions|
        merged_attributes = {}
        merged_references = {}
        definitions.each do |record|
          desired_attributes(record).merge(nested_attributes(record)).each do |key, value|
            if merged_attributes.key?(key) && merged_attributes[key] != value
              raise Error, "#{record.location}: contradictory #{record.code} attribute #{key} across seed definitions"
            end
            merged_attributes[key] = value
          end
          (SCOPE_ASSOCIATIONS.fetch(record.type, []) + record.references.keys).uniq.each do |key|
            next unless record.references.key?(key) || record.scope.key?(key)

            reference = record.references.key?(key) ? record.references[key] : record.scope[key]
            reference = local_code(reference.is_a?(Hash) ? reference.fetch("code") : reference)
            reference = root.call(reference) if parents.key?(reference)
            if merged_references.key?(key) && merged_references[key] != reference
              raise Error, "#{record.location}: contradictory #{record.code} reference #{key} across seed definitions"
            end
            merged_references[key] = reference
          end
        end
      end
    end

    def validate_record!(record)
      unless record.namespace == @namespace && record.catalog == @catalog
        raise Error, "#{record.location}: unexpected namespace/catalog #{record.namespace}/#{record.catalog}"
      end
      model = MODELS.fetch(record.type) { raise Error, "#{record.location}: unsupported type #{record.type}" }
      ([ record.code ] + record.aliases).each do |code|
        unless code.is_a?(String) && code.match?(/\A[A-Z0-9]+(?:[-_][A-Z0-9]+)*\z/) && code == local_code(code)
          raise Error, "#{record.location}: invalid local entity code #{code.inspect}"
        end
      end
      record.attributes.each_key do |key|
        next if NESTED_ATTRIBUTES.fetch(record.type, []).include?(key)

        if PROTECTED_ATTRIBUTES.include?(key) || key.end_with?("_id", "_type") || !model.column_names.include?(key)
          raise Error, "#{record.location}: unsupported #{record.type} attribute #{key}; associations use references"
        end
      end
      record.references.each_key do |key|
        raise Error, "#{record.location}: unsupported #{record.type} reference #{key}" unless model.reflect_on_association(key.to_sym)&.macro == :belongs_to
      end
      validate_ballot_lines!(record) if record.attributes.key?("ballot_lines")
      sequences = [ record.entity_sequence ] + record.references.values.filter_map { |reference| reference["entity_sequence"] if reference.is_a?(Hash) }
      if sequences.compact.any?
        raise Error, "#{record.location}: entity-sequence lookups are not supported by the Ascent importer yet; use exact codes"
      end
    end

    def validate_ballot_lines!(record)
      lines = record.attributes["ballot_lines"]
      raise Error, "#{record.location}: ballot_lines must be a list" unless lines.is_a?(Array)

      lines.each do |line|
        unless line.is_a?(Hash) && line["label"].is_a?(String) && line["label"].present? && (line.keys - BALLOT_LINE_KEYS).empty?
          raise Error, "#{record.location}: each ballot line needs a label and may only set #{BALLOT_LINE_KEYS.join(", ")}"
        end
        raise Error, "#{record.location}: unknown ballot line kind #{line["kind"]}" if line["kind"] && !BallotLine::KINDS.include?(line["kind"])
      end
      labels = lines.map { |line| line["label"] }
      raise Error, "#{record.location}: duplicate ballot line labels" if labels.uniq.length != labels.length
    end

    # Every reference, including a place's parent jurisdiction and its ballot lines' parties,
    # resolves before anything is written, so a record retried for a missing dependency never
    # leaves a partial write behind.
    def import_record(record)
      model = MODELS.fetch(record.type)
      desired = desired_attributes(record).merge(associations_for(record))
      parent = jurisdiction_parent(record, desired) if JURISDICTION_OWNERS.include?(record.type)
      lines = resolved_ballot_lines(record) if record.attributes.key?("ballot_lines")
      codes = ([ record.code ] + record.aliases).uniq
      bindings = codes.filter_map { |code| binding_for(code) }
      bindings.each do |binding|
        raise Error, "#{binding.code} already identifies #{binding.record_type}" unless binding.record_type == record.type
      end
      targets = codes.filter_map { |code| resolve_code(record.type, code) }.uniq(&:id)
      raise Error, "#{record.location}: aliases identify different #{record.type} records" if targets.length > 1

      target = targets.first || natural_target(model, desired)
      canonical_code = target&.entity_code.presence || bindings.first&.canonical_code || record.code
      codes |= [ canonical_code ]
      if target.nil?
        target = model.create!(desired.merge(entity_code: canonical_code))
        report[:created] << canonical_code
      else
        differences = desired.each_with_object({}) do |(key, value), result|
          current = comparison_value(model, key, target.public_send(key))
          incoming = comparison_value(model, key, value)
          result[key] = { existing: current, incoming: incoming } unless current == incoming
        end
        # Adoption via a natural key does not change the record's other fields.
        target.update!(entity_code: canonical_code) if target.entity_code.blank?
        if differences.empty?
          report[:unchanged] << canonical_code
        else
          report[:conflicts] << { code: canonical_code, differences: differences, source: record.source }
        end
      end
      target.jurisdiction || target.create_jurisdiction!(parent: parent) if JURISDICTION_OWNERS.include?(record.type)
      import_ballot_lines(target, lines, record, canonical_code) if lines
      register_codes(codes, canonical_code, target)
    end

    def register_codes(codes, canonical_code, target)
      @records[canonical_code] = target if @records
      codes.each do |code|
        binding = binding_for(code) || EntityCode.new(namespace: @namespace, catalog: @catalog, code: code)
        raise Error, "#{code} is permanently bound to #{binding.canonical_code}" if binding.persisted? && binding.canonical_code != canonical_code

        report[:aliases_added] << code if binding.new_record? && code != canonical_code
        binding.assign_attributes(canonical_code: canonical_code, record: target)
        binding.save! if binding.new_record? || binding.changed?
        @bindings[code] = binding if @bindings
      end
    end

    # Lines are added, never removed, so a partial capture cannot clear another line.
    # A differing existing line is reported rather than changed.
    def import_ballot_lines(candidacy, lines, record, canonical_code)
      existing_lines = candidacy.ballot_lines.index_by(&:label)
      lines.each.with_index(1) do |line, position|
        existing = existing_lines[line["label"]]
        if existing.nil?
          candidacy.ballot_lines.create!(line.merge("position" => position))
          report[:ballot_lines_added] << "#{canonical_code}: #{line["label"]}"
        else
          incoming = { "kind" => line["kind"], "party" => line["party"]&.id }
          current = { "kind" => existing.kind, "party" => existing.party_id }
          next if incoming == current

          report[:conflicts] << { code: canonical_code, ballot_line: line["label"], differences: { existing: current, incoming: incoming }, source: record.source }
        end
      end
    end

    # Definitions are compared as declared, so validation needs no database lookups.
    def nested_attributes(record)
      record.attributes.key?("ballot_lines") ? { "ballot_lines" => record.attributes["ballot_lines"] } : {}
    end

    def resolved_ballot_lines(record)
      record.attributes["ballot_lines"].map do |line|
        party = required_code("Party", line["party"], record) if line["party"]
        { "label" => line["label"], "kind" => line["kind"] || (party ? "party" : "unclassified"), "party" => party }
      end
    end

    # A place nests under the jurisdiction of the place that contains it; a District's comes from its state scope.
    def jurisdiction_parent(record, desired)
      parent_owner = case record.type
                     when "State" then desired["country"]
                     when "County" then desired["state"]
                     when "Municipality" then desired["county"] || desired["state"]
                     when "District" then (scoped_owner("State", "state", record) if record.scope["state"])
                     end
      parent_owner && jurisdiction_of(parent_owner)
    end

    # A place created by another seeder may still lack its jurisdiction.
    def jurisdiction_of(owner)
      return owner.jurisdiction if owner.jurisdiction

      parent_owner = case owner
                     when State then owner.country
                     when County then owner.state
                     when Municipality then owner.county || owner.state
                     end
      owner.create_jurisdiction!(parent: parent_owner && jurisdiction_of(parent_owner))
    end

    def cast_attributes(model, attributes)
      attributes.to_h do |key, value|
        column = model.columns_hash.fetch(key)
        if (values = model.defined_enums[key])
          raise Error, "#{model.name}.#{key} must be one of #{values.keys.join(", ")}" unless value.nil? || values.key?(value.to_s)
        elsif column.type == :date && !value.nil?
          value = Date.iso8601(value.to_s)
        elsif column.type == :integer && !value.nil? && !value.to_s.match?(/\A-?\d+\z/)
          raise Error, "#{model.name}.#{key} requires an integer"
        end
        [ key, model.type_for_attribute(key).cast(value) ]
      end
    rescue ArgumentError => e
      raise Error, "Invalid attribute for #{model.name}: #{e.message}"
    end

    def desired_attributes(record)
      model = MODELS.fetch(record.type)
      cast_attributes(model, record.attributes.except(*NESTED_ATTRIBUTES.fetch(record.type, [])))
    end

    def associations_for(record)
      model = MODELS.fetch(record.type)
      values = {}
      SCOPE_ASSOCIATIONS.fetch(record.type, []).each do |key|
        reference = record.references[key] || record.scope[key]
        values[key] = resolve_reference(model, key, reference, record) if reference
      end
      record.references.each do |key, reference|
        values[key] = reference.nil? ? nil : resolve_reference(model, key, reference, record)
      end
      values
    end

    def resolve_reference(model, key, reference, record)
      if reference.is_a?(Hash)
        if (reference["namespace"] && reference["namespace"] != @namespace) || (reference["catalog"] && reference["catalog"] != @catalog)
          raise Error, "#{record.location}: foreign references need an adapter for their catalog"
        end
        reference = reference.fetch("code")
      end
      case model.reflect_on_association(key.to_sym).klass.name
      when "Jurisdiction" then jurisdiction_of(owner_for(reference, record))
      when "Year" then year_for(reference, record)
      else required_code(model.reflect_on_association(key.to_sym).klass.name, reference, record)
      end
    end

    # A jurisdiction is referenced by the code of the place that owns it.
    def owner_for(code, record)
      code = local_code(code)
      type = EntityCode.find_by(namespace: @namespace, catalog: @catalog, code: code)&.record_type ||
             @reference_types[code] ||
             JURISDICTION_OWNERS.find { |owner| code.start_with?("#{owner.upcase}-") }
      raise Error, "#{record.location}: #{code} does not identify a jurisdiction" unless JURISDICTION_OWNERS.include?(type)

      required_code(type, code, record)
    end

    def scoped_owner(type, key, record)
      required_code(type, record.scope.fetch(key), record)
    end

    # Years are not coded; YEAR-2026 names the year itself.
    def year_for(code, record)
      number = local_code(code)[/\AYEAR-(\d{4})\z/, 1] or raise Error, "#{record.location}: invalid year reference #{code}"
      Year.find_by(year: number.to_i) || raise(MissingReference, "#{record.location}: missing Year #{number}")
    end

    def required_code(type, code, record)
      resolve_code(type, code) || raise(MissingReference, "#{record.location}: missing #{type} #{code}")
    end

    def natural_target(model, desired)
      keys = NATURAL_KEYS[model]
      return unless keys

      blank_allowed = BLANK_NATURAL_KEYS.fetch(model, [])
      return unless keys.all? { |key| desired[key].present? || desired.key?(key) && desired[key] == false || blank_allowed.include?(key) }

      model.find_by(keys.to_h { |key| [ key, desired[key] ] })
    end

    def comparison_value(model, key, value)
      return value unless model.reflect_on_association(key.to_sym)&.macro == :belongs_to
      return unless value

      value.id
    end

    def local_code(code)
      prefix = "#{@namespace}-#{@catalog}-"
      code.to_s.start_with?(prefix) ? code.to_s.delete_prefix(prefix) : code.to_s
    end
  end
end
