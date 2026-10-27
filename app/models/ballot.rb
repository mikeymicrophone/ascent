# The real races on a voter's ballot where they live, grouped from city to federal, with how far the
# voter has got on each, and the places beyond it where they can pretend vote.
class Ballot
  attr_reader :voter

  def initialize(voter)
    @voter = voter
  end

  # Every place the voter lives now; the ballot covers them all.
  def residences
    @residences ||= voter.current_residences.includes(:jurisdiction, :county, :congressional_district, :state_senate_district, :state_house_district).to_a
  end

  def races
    residences.any? ? Race.on_ballot_for(voter).with_naming_details.recent : Race.none
  end

  def mountains
    @mountains ||= races.map { Mountain.new(voter: voter, race: it) }
  end

  # [level, mountains] pairs in ballot order, leaving out levels with no races.
  def levels
    mountains.group_by { it.race.office.jurisdiction.ballot_level }
      .sort_by { |level, _| Jurisdiction::BALLOT_LEVELS.index(level) }
  end

  def progress_counts
    Mountain::PROGRESS_STATES.index_with(0).merge(mountains.map(&:progress).tally)
  end

  def next_election
    races.reorder("elections.election_date").first&.election
  end

  # Open real races elsewhere that a search finds, for pretend votes.
  def pretend_races(query)
    Race.real.open_to_rating.findable(query).where.not(id: races.select(:id))
  end

  def neighboring_races
    towns = residences.map(&:jurisdiction)
    neighbors = Jurisdiction.where(parent_id: towns.map(&:parent_id)).where.not(id: towns.map(&:id))
    residences.any? ? Race.real.open_to_rating.in_jurisdictions(neighbors).where.not(id: races.select(:id)) : Race.none
  end

  def mock_races
    Race.mock.open_to_rating.recent
  end

  # Finished races where the voter lives, to replay with approval voting.
  def historical_races
    residences.any? ? Race.historical.in_jurisdictions(voter.ballot_jurisdictions).recent : Race.none
  end
end
