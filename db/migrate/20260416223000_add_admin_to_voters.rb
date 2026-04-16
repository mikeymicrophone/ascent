# frozen_string_literal: true

class AddAdminToVoters < ActiveRecord::Migration[8.0]
  def change
    add_column :voters, :admin, :boolean, default: false, null: false
  end
end
