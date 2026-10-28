class AddPortraitsToPeople < ActiveRecord::Migration[8.1]
  def change
    add_column :people, :portrait_url, :string
    add_column :people, :portrait_credit, :string
    add_column :people, :portrait_source_url, :string
  end
end
