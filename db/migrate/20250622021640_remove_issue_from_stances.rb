class RemoveIssueFromStances < ActiveRecord::Migration[8.0]
  def change
    remove_reference :stances, :issue, null: false, foreign_key: true
  end
end
