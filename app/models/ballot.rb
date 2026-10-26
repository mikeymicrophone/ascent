# The real races on a voter's ballot where they live, grouped from city to federal, with how far the
# voter has got on each, and the places beyond it where they can pretend vote.
class Ballot
  attr_reader :voter

  def initialize(voter)
    @voter = voter
  end

  def residence
    voter.current_residence
  end

  def races
    residence ? Race.on_ballot_for(residence).with_naming_details.recent : Race.none
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
    residence ? Race.real.open_to_rating.in_jurisdictions(residence.neighboring_jurisdictions) : Race.none
  end

  def mock_races
    Race.mock.open_to_rating.recent
  end

  # Finished races where the voter lives, to replay with approval voting.
  def historical_races
    residence ? Race.historical.in_jurisdictions(residence.ballot_jurisdictions).recent : Race.none
  end
end
