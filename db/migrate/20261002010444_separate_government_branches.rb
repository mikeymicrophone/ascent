class SeparateGovernmentBranches < ActiveRecord::Migration[8.1]
  LEGISLATIVE = 0
  EXECUTIVE = 1

  def up
    add_column :governing_bodies, :branch, :integer
    add_column :positions, :branch, :integer

    create_table :chambers do |t|
      t.references :governing_body, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :chambers, [ :governing_body_id, :name ], unique: true

    add_reference :offices, :governing_body, foreign_key: true
    add_reference :offices, :chamber, foreign_key: true

    execute <<~SQL
      UPDATE positions
      SET branch = CASE WHEN is_executive THEN #{EXECUTIVE} ELSE #{LEGISLATIVE} END
    SQL

    remove_column :positions, :is_executive
    remove_column :governance_types, :authority_level

    consolidate_governance_types
  end

  def down
    add_column :governance_types, :authority_level, :integer
    add_column :positions, :is_executive, :boolean, default: false, null: false

    execute <<~SQL
      UPDATE positions
      SET is_executive = (branch = #{EXECUTIVE})
    SQL

    remove_reference :offices, :chamber, foreign_key: true
    remove_reference :offices, :governing_body, foreign_key: true
    drop_table :chambers
    remove_column :positions, :branch
    remove_column :governing_bodies, :branch
  end

  private

  def consolidate_governance_types
    legislature_id = ensure_governance_type(
      "Legislature",
      "A lawmaking institution. Congress and a state legislature share this type; the body's jurisdiction supplies the level.",
      "Majority vote of the members"
    )
    ensure_governance_type(
      "Court",
      "A judicial institution that hears cases and interprets law.",
      "Decision by the judges of the court"
    )
    council_id = ensure_governance_type(
      "Council",
      "A local lawmaking institution, such as a city council.",
      "Majority vote of the members"
    )
    board_id = ensure_governance_type(
      "Board",
      "A governing board for a school district or special district.",
      "Majority vote of the board"
    )
    executive_id = ensure_governance_type(
      "Executive",
      "The institution headed by an elected executive, such as a president, governor, or county executive.",
      "Decision by the executive"
    )

    remap [ "County Legislature", "State Legislature", "Federal Legislature" ], legislature_id, LEGISLATIVE
    remap [ "Municipal Legislature" ], council_id, LEGISLATIVE
    remap [ "County Executive", "State Executive", "Federal Executive" ], executive_id, EXECUTIVE
    remap [ "School Board", "Special District Board" ], board_id, nil

    old_names = [
      "Municipal Legislature",
      "County Executive",
      "County Legislature",
      "State Legislature",
      "State Executive",
      "School Board",
      "Special District Board",
      "Federal Legislature",
      "Federal Executive"
    ]
    execute <<~SQL
      DELETE FROM governance_types
      WHERE name IN (#{quoted_list(old_names)})
    SQL
  end

  def ensure_governance_type(name, description, decision_making_process)
    existing_id = select_value("SELECT id FROM governance_types WHERE name = #{quote(name)}")
    return existing_id if existing_id

    execute <<~SQL
      INSERT INTO governance_types (name, description, decision_making_process, created_at, updated_at)
      VALUES (
        #{quote(name)},
        #{quote(description)},
        #{quote(decision_making_process)},
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
      )
    SQL
    select_value("SELECT id FROM governance_types WHERE name = #{quote(name)}")
  end

  def remap(old_names, governance_type_id, branch)
    branch_sql = branch.nil? ? "NULL" : branch.to_s
    execute <<~SQL
      UPDATE governing_bodies
      SET governance_type_id = #{governance_type_id}, branch = #{branch_sql}
      WHERE governance_type_id IN (
        SELECT id FROM governance_types WHERE name IN (#{quoted_list(old_names)})
      )
    SQL
  end

  def quoted_list(names)
    names.map { |name| quote(name) }.join(", ")
  end

  def quote(value)
    connection.quote(value)
  end
end
