# Every rating that counts toward a race's results: the voter has saved a baseline for the race, and
# a candidate from the primaries counts only while the voter includes them.
class CreateMountainRatings < ActiveRecord::Migration[8.1]
  def change
    create_view :mountain_ratings
  end
end
