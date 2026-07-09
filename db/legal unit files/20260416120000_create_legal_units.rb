class CreateLegalUnits < ActiveRecord::Migration[8.1]
  def change
    create_table :lu_corpora do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :short_name
      t.string :jurisdiction, null: false
      t.string :publication_kind, null: false, default: 'code'
      t.string :source_url
      t.text :notes
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lu_corpora, [:jurisdiction, :slug], unique: true

    create_table :lu_editions do |t|
      t.references :corpus, null: false, foreign_key: { to_table: :lu_corpora, on_delete: :cascade }, index: true
      t.string :label, null: false
      t.date :effective_on
      t.date :published_on
      t.string :status, null: false, default: 'published'
      t.string :source_digest
      t.string :source_url
      t.jsonb :source_metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lu_editions, [:corpus_id, :label], unique: true
    add_index :lu_editions, :effective_on
    add_index :lu_editions, :published_on

    create_table :lu_units do |t|
      t.references :edition, null: false, foreign_key: { to_table: :lu_editions, on_delete: :cascade }, index: true
      t.references :parent, foreign_key: { to_table: :lu_units, on_delete: :cascade }, index: true
      t.string :official_kind, null: false
      t.string :normalized_kind, null: false
      t.string :designator
      t.text :heading
      t.text :body
      t.string :citation
      t.integer :position, null: false, default: 0
      t.integer :depth, null: false, default: 0
      t.string :path
      t.string :status, null: false, default: 'active'
      t.date :starts_on
      t.date :ends_on
      t.jsonb :text_metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lu_units, [:edition_id, :citation], unique: true, where: 'citation IS NOT NULL'
    add_index :lu_units, [:edition_id, :path], unique: true, where: 'path IS NOT NULL'
    add_index :lu_units, [:edition_id, :normalized_kind]
    add_index :lu_units, [:edition_id, :designator]
    add_index :lu_units, [:edition_id, :status]
    add_index :lu_units, [:edition_id, :parent_id, :position], name: 'index_lu_units_on_edition_parent_position'

    create_table :lu_citation_aliases do |t|
      t.references :unit, null: false, foreign_key: { to_table: :lu_units, on_delete: :cascade }, index: true
      t.string :citation, null: false
      t.string :citation_type, null: false, default: 'alternate'
      t.integer :position, null: false, default: 0
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lu_citation_aliases, [:unit_id, :citation], unique: true
    add_index :lu_citation_aliases, :citation
    add_index :lu_citation_aliases, :citation_type

    create_table :lu_references do |t|
      t.references :edition, null: false, foreign_key: { to_table: :lu_editions, on_delete: :cascade }, index: true
      t.references :source_unit, null: false, foreign_key: { to_table: :lu_units, on_delete: :cascade }, index: true
      t.references :target_unit, foreign_key: { to_table: :lu_units, on_delete: :nullify }, index: true
      t.string :raw_citation, null: false
      t.string :target_citation
      t.string :reference_type, null: false, default: 'cross_reference'
      t.integer :text_span_start
      t.integer :text_span_end
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lu_references, [:edition_id, :reference_type]
    add_index :lu_references, :raw_citation
    add_index :lu_references, :target_citation

    create_table :lu_definitions do |t|
      t.references :unit, null: false, foreign_key: { to_table: :lu_units, on_delete: :cascade }, index: true
      t.references :defined_unit, foreign_key: { to_table: :lu_units, on_delete: :nullify }, index: true
      t.string :term, null: false
      t.text :meaning
      t.string :scope_type, null: false, default: 'local'
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lu_definitions, [:unit_id, :term], unique: true
    add_index :lu_definitions, :term
    add_index :lu_definitions, :scope_type

    create_table :lu_projections do |t|
      t.references :unit, null: false, foreign_key: { to_table: :lu_units, on_delete: :cascade }, index: true
      t.string :projection_type, null: false
      t.string :format, null: false, default: 'json'
      t.jsonb :content, null: false, default: {}
      t.string :generator
      t.decimal :confidence, precision: 5, scale: 4
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :lu_projections, [:unit_id, :projection_type]
    add_index :lu_projections, :format
    add_index :lu_projections, :generator
    add_index :lu_projections, :content, using: :gin
  end
end
