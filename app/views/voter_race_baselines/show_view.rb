class Views::VoterRaceBaselines::ShowView < Views::ApplicationView
  def initialize(voter_race_baseline:, notice: nil)
    @voter_race_baseline = voter_race_baseline
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold voter_race_baseline-show", id: dom_id(@voter_race_baseline, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing voter race baseline" }
      
      VoterRaceBaselinePartial(voter_race_baseline: @voter_race_baseline)
      
      Ui::ResourceActions(resource: @voter_race_baseline)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end