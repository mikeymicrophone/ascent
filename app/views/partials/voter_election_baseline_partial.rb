class Views::Partials::VoterElectionBaselinePartial < Views::ApplicationView
  def initialize(voter_election_baseline:)
    @voter_election_baseline = voter_election_baseline
  end

  def view_template(&)
    div(id: dom_id(@voter_election_baseline), class: "voter_election_baseline-partial") do
      h3 { "#{@voter_election_baseline.voter.name} had baseline of" }
      div do
        span { @voter_election_baseline.baseline }
        span { " on " }
        whitespace
        link_to @voter_election_baseline.election.name, @voter_election_baseline.election, class: "link election"

        if @voter_election_baseline.has_archives?
          span { " (After establishing prior baselines of: " }
          @voter_election_baseline.baseline_history.map { it.baseline }.to_sentence
          span { ")" }
        end
      end
    end
  end
end
