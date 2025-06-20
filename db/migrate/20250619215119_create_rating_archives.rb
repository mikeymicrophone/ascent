class CreateRatingArchives < ActiveRecord::Migration[8.0]
  def change
    create_table :rating_archives do |t|
      t.references :voter, null: false, foreign_key: true
      t.references :candidacy, null: false, foreign_key: true
      t.integer :rating
      t.integer :baseline
      t.datetime :archived_at
      t.string :reason

      t.timestamps
    end
  end
end
