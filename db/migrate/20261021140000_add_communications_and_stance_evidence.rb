class AddCommunicationsAndStanceEvidence < ActiveRecord::Migration[8.1]
  def up
    create_table :channels do |t|
      t.references :owner, polymorphic: true
      t.string :platform, null: false
      t.string :handle, null: false
      t.string :url
      t.boolean :official, null: false, default: false
      t.string :entity_code
      t.timestamps
    end
    add_index :channels, [ :platform, :handle ], unique: true
    add_index :channels, :entity_code, unique: true

    create_table :communications do |t|
      t.references :channel, foreign_key: true
      t.string :kind, null: false
      t.string :title
      t.date :published_on, null: false
      t.string :url, null: false
      t.string :platform_id
      t.string :archived_url
      t.string :availability, null: false, default: "available"
      t.text :summary
      t.integer :duration_seconds
      t.string :language
      t.string :entity_code
      t.timestamps
    end
    add_index :communications, :url, unique: true
    add_index :communications, :entity_code, unique: true

    create_table :communication_features do |t|
      t.references :communication, null: false, foreign_key: true
      t.references :candidacy, null: false, foreign_key: true
      t.timestamps
    end
    add_index :communication_features, [ :communication_id, :candidacy_id ], unique: true

    create_table :stance_evidences do |t|
      t.references :stance, null: false, foreign_key: true
      t.references :communication, null: false, foreign_key: true
      t.string :relation, null: false, default: "states"
      t.text :quote
      t.integer :offset_seconds
      t.string :entity_code
      t.timestamps
    end
    add_index :stance_evidences, [ :stance_id, :communication_id ], unique: true
    add_index :stance_evidences, :entity_code, unique: true

    guard_duplicate_stances!
    add_column :stances, :entity_code, :string
    add_index :stances, :entity_code, unique: true
    add_index :stances, [ :candidacy_id, :approach_id ], unique: true
  end

  def down
    remove_index :stances, [ :candidacy_id, :approach_id ]
    remove_index :stances, :entity_code
    remove_column :stances, :entity_code
    drop_table :stance_evidences
    drop_table :communication_features
    drop_table :communications
    drop_table :channels
  end

  private

  def guard_duplicate_stances!
    duplicate = select_one(<<~SQL)
      SELECT candidacy_id, approach_id FROM stances GROUP BY candidacy_id, approach_id HAVING COUNT(*) > 1 LIMIT 1
    SQL
    return unless duplicate

    raise ActiveRecord::MigrationError,
      "Candidacy #{duplicate.fetch("candidacy_id")} has more than one stance on approach #{duplicate.fetch("approach_id")}; " \
      "merge them before migrating. No rows were changed."
  end
end
