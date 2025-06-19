class RemoveBaselineFromRatings < ActiveRecord::Migration[8.0]
  def change
    remove_column :ratings, :baseline, :integer
    remove_column :rating_archives, :baseline, :integer
  end
end
