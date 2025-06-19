class Views::Elections::ShowView < Views::ApplicationView
  def initialize(election:, notice: nil)
    @election = election
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold election-show", id: dom_id(@election, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing election" }
      
      Views::Elections::ElectionPartial(election: @election)
      
      div do
        link_to "Edit this election", 
                edit_election_path(@election),
                class: "secondary"
        link_to "Back to elections", 
                elections_path,
                class: "secondary"
        button_to "Destroy this election", 
                  @election,
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