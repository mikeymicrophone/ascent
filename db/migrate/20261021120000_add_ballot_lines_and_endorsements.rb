class AddBallotLinesAndEndorsements < ActiveRecord::Migration[8.1]
  def up
    create_table :parties do |t|
      t.references :state, null: false, foreign_key: true
      t.string :name, null: false
      t.string :abbreviation
      t.string :entity_code
      t.timestamps
    end
    add_index :parties, [ :state_id, :name ], unique: true
    add_index :parties, :entity_code, unique: true

    create_table :ballot_lines do |t|
      t.references :candidacy, null: false, foreign_key: true
      t.references :party, foreign_key: true
      t.string :label, null: false
      t.string :kind, null: false, default: "unclassified"
      t.integer :position
      t.timestamps
    end
    add_index :ballot_lines, [ :candidacy_id, :label ], unique: true

    create_table :endorsements do |t|
      t.references :candidacy, null: false, foreign_key: true
      t.references :endorser, polymorphic: true, null: false
      t.references :ballot_line, foreign_key: true, index: { unique: true }
      t.string :kind, null: false, default: "public"
      t.integer :strength
      t.date :endorsed_on
      t.date :withdrawn_on
      t.text :notes
      t.timestamps
    end
    add_index :endorsements, [ :candidacy_id, :endorser_type, :endorser_id, :kind ], unique: true,
      name: "index_endorsements_on_candidacy_endorser_and_kind"

    add_column :candidacies, :participation, :string, null: false, default: "active"
    add_column :races, :certification_status, :string

    guard_party_affiliations!
    remove_column :candidacies, :party_affiliation
  end

  def down
    add_column :candidacies, :party_affiliation, :string
    execute <<~SQL
      UPDATE candidacies
      SET party_affiliation = lines.labels
      FROM (
        SELECT candidacy_id, string_agg(label, '; ' ORDER BY position, id) AS labels
        FROM ballot_lines
        GROUP BY candidacy_id
      ) AS lines
      WHERE lines.candidacy_id = candidacies.id
    SQL
    remove_column :races, :certification_status
    remove_column :candidacies, :participation
    drop_table :endorsements
    drop_table :ballot_lines
    drop_table :parties
  end

  private

  # Printed labels cannot be classified as parties, designations, or petitions here; reseed them instead.
  def guard_party_affiliations!
    return unless select_value("SELECT COUNT(*) FROM candidacies WHERE party_affiliation IS NOT NULL AND party_affiliation <> ''").to_i.positive?

    raise ActiveRecord::MigrationError,
      "Candidacies still carry party_affiliation text. Reseed them as ballot lines, or clear the column, before migrating. No rows were changed."
  end
end
