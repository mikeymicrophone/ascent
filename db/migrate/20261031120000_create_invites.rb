class CreateInvites < ActiveRecord::Migration[8.1]
  def change
    add_column :voters, :invite_token, :string
    reversible do |direction|
      direction.up do
        voter_class = Class.new(ActiveRecord::Base) { self.table_name = "voters" }
        voter_class.find_each do |voter|
          voter.update_columns(invite_token: SecureRandom.base58(24))
        end
      end
    end
    change_column_null :voters, :invite_token, false
    add_index :voters, :invite_token, unique: true

    create_table :invites do |t|
      t.references :inviter, null: false, foreign_key: { to_table: :voters, on_delete: :cascade }
      t.references :invitee, null: false, foreign_key: { to_table: :voters, on_delete: :cascade }, index: { unique: true }
      t.timestamps
      t.check_constraint "inviter_id <> invitee_id", name: "invites_cannot_invite_self"
    end
  end
end
