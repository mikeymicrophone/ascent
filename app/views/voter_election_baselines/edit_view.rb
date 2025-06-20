class Views::VoterElectionBaselines::EditView < Views::ApplicationView
  def initialize(voter_election_baseline:)
    @voter_election_baseline = voter_election_baseline
  end

  def view_template(&)
    div(class: "scaffold voter_election_baseline-edit", id: dom_id(@voter_election_baseline, :edit)) do
      h1 { "Editing voter election baseline" }
      
      Views::VoterElectionBaselines::VoterElectionBaselineForm(voter_election_baseline: @voter_election_baseline)
      
      div do
        link_to "Show this voter election baseline", 
                @voter_election_baseline,
                class: "secondary"
        link_to "Back to voter election baselines", 
                voter_election_baselines_path,
                class: "secondary"
      end
    end
  end
end