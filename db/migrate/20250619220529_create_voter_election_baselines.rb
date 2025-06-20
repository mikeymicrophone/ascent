class CreateVoterElectionBaselines < ActiveRecord::Migration[8.0]
  def change
    create_table :voter_election_baselines do |t|
      t.references :voter, null: false, foreign_key: true
      t.references :election, null: false, foreign_key: true
      t.integer :baseline

      t.timestamps
    end
  end
end
