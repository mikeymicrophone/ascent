module SeedJurisdictions
  module_function

  def ensure(owner, parent: nil)
    owner.jurisdiction || owner.create_jurisdiction!(parent: parent)
  end

  # Sourced races on one date in one jurisdiction share a single general election.
  def general_election(jurisdiction, date)
    date = Date.iso8601(date.to_s)

    Election.find_or_create_by!(jurisdiction: jurisdiction, election_date: date, is_mock: false) do |election|
      election.name = "#{jurisdiction.name} General Election #{date.year}"
      election.kind = "general"
      election.year = Year.find_by!(year: date.year)
      election.status = "upcoming"
      election.is_historical = false
    end
  end
end
