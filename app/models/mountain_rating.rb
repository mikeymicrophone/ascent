# A rating as the results count it, read from the mountain_ratings view: the voter has saved a
# baseline for the race, and a candidate from the primaries counts only while the voter includes them.
class MountainRating < ApplicationRecord
  # The band width for rating distributions: ten bands from 0-49 to 450-500.
  RATING_BAND = 50

  belongs_to :voter
  belongs_to :candidacy
  belongs_to :race

  scope :approved, -> { where(approved: true) }
  scope :counted_with, ->(group) { where(counted_as: group) }
  scope :on_ballot, -> { where(from_primary: false) }
  scope :from_primaries, -> { where(from_primary: true) }
  # Each rating's place on its voter's mountain, and how many candidates share that rating.
  scope :ranked_within_mountain, -> {
    select("mountain_ratings.*",
           "rank() OVER (PARTITION BY mountain_ratings.voter_id ORDER BY mountain_ratings.rating DESC) AS place",
           "count(*) OVER (PARTITION BY mountain_ratings.voter_id, mountain_ratings.rating) AS tied")
  }
  scope :by_rating_band, -> { group(Arel.sql("LEAST(mountain_ratings.rating / #{RATING_BAND}, 9)")) }

  # Each voter's highest-rated candidates in the given ratings, as rows that carry `tied`, so a tie
  # splits that voter's first choice between the candidates in it.
  def self.first_choices(ratings)
    from(ratings.ranked_within_mountain, :mountain_ratings).where(place: 1)
  end

  def readonly?
    true
  end
end
