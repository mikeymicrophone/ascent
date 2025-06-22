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
      
      div do
        link_to "Edit this voter", 
                edit_voter_path(@voter),
                class: "secondary"
        link_to "Back to voters", 
                voters_path,
                class: "secondary"
        button_to "Destroy this voter", 
                  @voter,
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