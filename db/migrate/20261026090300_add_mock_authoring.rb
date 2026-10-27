# Anyone may make a mock election. It records who made it, and its invented candidates are marked
# so they never pass for real people.
class AddMockAuthoring < ActiveRecord::Migration[8.1]
  def change
    add_reference :elections, :creator, foreign_key: { to_table: :voters, on_delete: :nullify }
    add_column :people, :fictional, :boolean, null: false, default: false
  end
end
