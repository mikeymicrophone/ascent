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
      
      Ui::ResourceActions(resource: @voter_election_baseline)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end