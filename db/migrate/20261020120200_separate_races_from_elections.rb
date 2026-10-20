class SeparateRacesFromElections < ActiveRecord::Migration[8.1]
  def change
    add_reference :elections, :jurisdiction, null: false, foreign_key: true
    add_column :elections, :name, :string, null: false
    add_column :elections, :kind, :string
    add_column :elections, :early_voting_starts_on, :date
    add_column :elections, :early_voting_ends_on, :date
    change_column_null :elections, :election_date, false
    add_check_constraint :elections,
      "early_voting_starts_on <= early_voting_ends_on",
      name: "elections_early_voting_dates_ordered"
    add_check_constraint :elections,
      "early_voting_starts_on <= election_date AND early_voting_ends_on <= election_date",
      name: "elections_early_voting_before_election_date"

    create_table :races do |t|
      t.references :election, null: false, foreign_key: true
      t.references :office, null: false, foreign_key: true
      t.string :status, null: false, default: "upcoming"
      t.text :description
      t.timestamps
    end
    remove_reference :elections, :office, null: false, foreign_key: true

    remove_reference :candidacies, :election, null: false, foreign_key: true
    add_reference :candidacies, :race, null: false, foreign_key: true

    remove_reference :voter_election_baselines, :election, null: false, foreign_key: true
    rename_table :voter_election_baselines, :voter_race_baselines
    add_reference :voter_race_baselines, :race, null: false, foreign_key: true
    add_index :voter_race_baselines, [ :voter_id, :race_id ], unique: true,
      name: "index_voter_race_baselines_on_voter_and_race"

    remove_index :voter_election_baseline_archives, [ :voter_id, :election_id ],
      name: "index_baseline_archives_on_voter_and_election"
    remove_reference :voter_election_baseline_archives, :election, null: false, foreign_key: true
    rename_table :voter_election_baseline_archives, :voter_race_baseline_archives
    add_reference :voter_race_baseline_archives, :race, null: false, foreign_key: true
    add_index :voter_race_baseline_archives, [ :voter_id, :race_id ],
      name: "index_baseline_archives_on_voter_and_race"
  end
end
