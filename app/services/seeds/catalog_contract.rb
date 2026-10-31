# frozen_string_literal: true

module Seeds
  # Exports the fields the live importer accepts, in the contract format the shared
  # micharisma_seeders schema exporter reads, ported from AthleteAce. Required associations
  # stay semantic checks because they may arrive through inherited scope.
  class CatalogContract
    CODE = { "type" => "string", "pattern" => "^[A-Z0-9]+(?:[-_][A-Z0-9]+)*$" }.freeze

    def self.document
      entities = LibraryImporter::MODELS.sort.to_h do |name, model|
        association_columns = LibraryImporter.association_columns(model)
        attributes = model.columns.sort_by(&:name).filter_map do |column|
          next if LibraryImporter::PROTECTED_ATTRIBUTES.include?(column.name) || association_columns.include?(column.name) || absent?(model, column.name) ||
            LibraryImporter::UNSEEDED_ATTRIBUTES.fetch(name, []).include?(column.name)

          [ column.name, column_schema(model, column) ]
        end.to_h
        attributes.merge!(nested_schemas(name))
        [ name, { "attributes" => attributes.sort.to_h, "references" => model.reflect_on_all_associations(:belongs_to).map { |association| association.name.to_s }.select { LibraryImporter.seeded_reference?(name, model, it) }.sort } ]
      end
      { "namespace" => "MIC", "catalog" => "ASC", "entities" => entities }
    end

    # A column the model requires to be blank, such as a party's kind, is not part of its contract.
    def self.absent?(model, attribute)
      model.validators_on(attribute.to_sym).any? { it.is_a?(ActiveModel::Validations::AbsenceValidator) }
    end

    def self.column_schema(model, column)
      allowed = allowed_values(model, column.name)
      schema = if allowed
                 { "type" => "string", "enum" => allowed }
      else
                 case column.type
                 when :integer, :bigint then { "type" => "integer" }
                 when :float, :decimal then { "type" => "number" }
                 when :boolean then { "type" => "boolean" }
                 when :date then { "type" => "string", "format" => "date" }
                 when :datetime, :timestamp then { "type" => "string", "format" => "date-time" }
                 when :json, :jsonb then {}
                 else { "type" => "string" }
                 end
      end
      schema = { "type" => "array", "items" => schema } if column.respond_to?(:array) && column.array
      schema["pattern"] = "^[0-9]{5}$" if model == County && column.name == "fips"
      column.null && !schema.empty? ? { "anyOf" => [ schema, { "type" => "null" } ] } : schema
    end

    # A Rails enum's names, or the word list of an inclusion validation.
    def self.allowed_values(model, attribute)
      return model.defined_enums[attribute].keys if model.defined_enums[attribute]

      inclusion = model.validators_on(attribute.to_sym).find { |validator| validator.is_a?(ActiveModel::Validations::InclusionValidator) }
      values = inclusion&.options&.fetch(:in, nil)
      values if values.is_a?(Array) && values.all?(String)
    end

    # Lists that the importer writes into their own records: ballot lines and featured candidacies.
    def self.nested_schemas(name)
      case name
      when "Candidacy"
        line = {
          "type" => "object", "additionalProperties" => false, "required" => [ "label" ],
          "properties" => { "label" => { "type" => "string", "minLength" => 1 }, "kind" => { "type" => "string", "enum" => BallotLine::KINDS }, "party" => CODE }
        }
        { "ballot_lines" => { "type" => "array", "items" => line } }
      when "Communication"
        { "featured_candidacies" => { "type" => "array", "items" => CODE, "uniqueItems" => true } }
      else
        {}
      end
    end
  end
end
