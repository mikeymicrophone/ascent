class AddEntityCodesToIssueLibrary < ActiveRecord::Migration[8.1]
  def change
    %i[topics issues approaches].each do |table|
      add_column table, :entity_code, :string
      add_index table, :entity_code, unique: true
    end
  end
end
