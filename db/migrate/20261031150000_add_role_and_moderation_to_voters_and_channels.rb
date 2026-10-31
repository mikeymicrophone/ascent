class AddRoleAndModerationToVotersAndChannels < ActiveRecord::Migration[8.0]
  def up
    add_column :voters, :role, :string
    add_column :voters, :profile_hidden, :boolean, default: false, null: false
    add_index :voters, :role
    add_index :voters, :profile_hidden

    execute <<~SQL.squish
      UPDATE voters SET role = 'admin' WHERE admin = TRUE
    SQL

    remove_column :voters, :admin

    add_column :channels, :review_status, :string, default: "pending", null: false
    add_reference :channels, :reviewed_by, foreign_key: { to_table: :voters }
    add_column :channels, :reviewed_at, :datetime
    add_index :channels, :review_status
  end

  def down
    remove_index :channels, :review_status
    remove_column :channels, :reviewed_at
    remove_reference :channels, :reviewed_by, foreign_key: { to_table: :voters }
    remove_column :channels, :review_status

    add_column :voters, :admin, :boolean, default: false, null: false

    execute <<~SQL.squish
      UPDATE voters SET admin = TRUE WHERE role = 'admin'
    SQL

    remove_index :voters, :profile_hidden
    remove_index :voters, :role
    remove_column :voters, :profile_hidden
    remove_column :voters, :role
  end
end
