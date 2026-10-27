module RaceHelpers
  # An office's contest sits inside an election held in the office's own jurisdiction.
  # The election trait (:upcoming, :active, :completed, :cancelled, :historical) also sets the race status.
  def create_race_for(office, election_trait = :upcoming, **election_attributes)
    election = create(:election, election_trait, jurisdiction: office.jurisdiction, **election_attributes)
    create(:race, office: office, election: election, status: election.status)
  end
end

RSpec.configure do |config|
  config.include RaceHelpers
end
