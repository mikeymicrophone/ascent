class AllowMultipleInfluencers < ActiveRecord::Migration[8.1]
  def change
    remove_index :invites, :invitee_id, unique: true
    add_index :invites, :invitee_id
    add_index :invites, [ :inviter_id, :invitee_id ], unique: true
    add_column :voters, :public_influencer, :boolean, null: false, default: false
  end
end
