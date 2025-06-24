class Views::Voters::ShowView < Views::ApplicationView
  def initialize(voter:, notice: nil)
    @voter = voter
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold voter-show", id: dom_id(@voter, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing voter" }
      
      VoterPartial(voter: @voter)
      
      Ui::ResourceActions(resource: @voter)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end