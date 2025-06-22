class Views::Partials::VoterElectionBaselinePartial < Views::ApplicationView
  def initialize(voter_election_baseline:)
    @voter_election_baseline = voter_election_baseline
  end

  def view_template(&)
    div(id: dom_id(@voter_election_baseline), class: "voter_election_baseline-partial") do
      h3 { @voter_election_baseline.voter_id }
      div do
        span { "Election:" }
        whitespace
        link_to @voter_election_baseline.election.name, @voter_election_baseline.election, class: "link election"
      end
      div do
        span { "Baseline:" }
        whitespace
        span { @voter_election_baseline.baseline }
      end
    end
  end
end