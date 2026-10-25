# The account a voter signs in with through another service, such as Google.
class AddOmniauthIdentityToVoters < ActiveRecord::Migration[8.1]
  def change
    add_column :voters, :provider, :string
    add_column :voters, :uid, :string
    add_index :voters, [ :provider, :uid ], unique: true
  end
end
