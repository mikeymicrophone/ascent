class Views::VoterElectionBaselines::ShowView < Views::ApplicationView
  def initialize(voter_election_baseline:, notice: nil)
    @voter_election_baseline = voter_election_baseline
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold voter_election_baseline-show", id: dom_id(@voter_election_baseline, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing voter election baseline" }
      
      VoterElectionBaselinePartial(voter_election_baseline: @voter_election_baseline)
      
      div do
        link_to "Edit this voter election baseline", 
                edit_voter_election_baseline_path(@voter_election_baseline),
                class: "secondary"
        link_to "Back to voter election baselines", 
                voter_election_baselines_path,
                class: "secondary"
        button_to "Destroy this voter election baseline", 
                  @voter_election_baseline,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end