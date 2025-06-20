class CreateVoterElectionBaselineArchives < ActiveRecord::Migration[8.0]
  def change
    create_table :voter_election_baseline_archives do |t|
      t.references :voter, null: false, foreign_key: true
      t.references :election, null: false, foreign_key: true
      t.integer :baseline, null: false
      t.datetime :archived_at, null: false
      t.string :reason, null: false
      t.integer :previous_baseline # Store the old baseline value
      t.integer :new_baseline # Store the new baseline value

      t.timestamps
    end
    
    add_index :voter_election_baseline_archives, [:voter_id, :election_id], 
              name: 'index_baseline_archives_on_voter_and_election'
    add_index :voter_election_baseline_archives, :archived_at
  end
end
