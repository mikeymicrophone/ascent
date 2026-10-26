# What one group's saved mountains for a race add up to: residents' by default, or visitors' pretend
# votes. Results are totals only, and any total drawn from fewer than MINIMUM_MOUNTAINS mountains is
# withheld, so a small ward cannot reveal how one person voted.
class RaceResults
  GROUPS = %w[resident visitor].freeze
  MINIMUM_MOUNTAINS = 10

  attr_reader :race, :group

  def initialize(race, group: "resident")
    @race = race
    @group = GROUPS.include?(group) ? group : GROUPS.first
  end

  def mountains
    race.voter_race_baselines.where(counted_as: group)
  end

  def ratings
    race.mountain_ratings.counted_with(group)
  end

  def mountain_count
    @mountain_count ||= mountains.count
  end

  def publishable?
    mountain_count >= MINIMUM_MOUNTAINS
  end

  # Percent of mountains approving each candidacy on the ballot, unapproved ones at zero.
  def approval_shares
    shares_of_mountains race.candidacies.not_from_primaries.ids.index_with(0).merge(ratings.on_ballot.approved.group(:candidacy_id).count)
  end

  # Percent of mountains whose highest rating went to each candidacy, a tie splitting the voter evenly:
  # the plurality count the same mountains would give.
  def first_choice_shares
    shares_of_mountains MountainRating.first_choices(ratings.on_ballot).group(:candidacy_id).sum("1.0 / tied")
  end

  def average_approvals
    mountain_count.zero? ? 0.0 : (ratings.on_ballot.approved.count.to_f / mountain_count).round(1)
  end

  def multiple_approval_share
    percent ratings.on_ballot.approved.group(:voter_id).having("count(*) > 1").count.size, mountain_count
  end

  def median_baseline
    mountains.median(:baseline)&.round
  end

  # Approval of candidates from the primaries, among only the voters who chose to include them.
  def off_ballot
    including = race.voter_race_preferences.where(include_primary_candidates: true, voter_id: mountains.select(:voter_id)).count
    return { mountain_count: including, approval_shares: {} } if including < MINIMUM_MOUNTAINS

    { mountain_count: including, approval_shares: percents(ratings.from_primaries.approved.group(:candidacy_id).count, including) }
  end

  # Of the mountains approving one candidacy, the percent also approving another, keyed [one, other].
  def shared_support
    approvals = ratings.on_ballot.approved.group(:candidacy_id).count
    ratings.on_ballot.approved
      .joins("INNER JOIN mountain_ratings AS also_approved ON also_approved.voter_id = mountain_ratings.voter_id " \
             "AND also_approved.race_id = mountain_ratings.race_id AND also_approved.approved " \
             "AND NOT also_approved.from_primary AND also_approved.candidacy_id <> mountain_ratings.candidacy_id")
      .group(:candidacy_id, "also_approved.candidacy_id").count
      .to_h { |(one, other), both| [ [ one, other ], percent(both, approvals[one]) ] }
  end

  # How many mountains put each candidacy in each 50-point band, keyed [candidacy id, band 0-9].
  def rating_distribution
    ratings.on_ballot.group(:candidacy_id).by_rating_band.count
  end

  def summary
    return { group: group, mountain_count: mountain_count, publishable: false } unless publishable?

    {
      group: group,
      mountain_count: mountain_count,
      publishable: true,
      approval_shares: approval_shares,
      first_choice_shares: first_choice_shares,
      average_approvals: average_approvals,
      multiple_approval_share: multiple_approval_share,
      median_baseline: median_baseline,
      off_ballot: off_ballot,
      shared_support: shared_support,
      rating_distribution: rating_distribution
    }
  end

  private

  def shares_of_mountains(counts)
    percents(counts, mountain_count)
  end

  def percents(counts, total)
    counts.transform_values { percent(it, total) }
  end

  def percent(count, total)
    total.zero? ? 0.0 : (count.to_f / total * 100).round(1)
  end
end
