class Views::Elections::ShowView < Views::ApplicationView
  def initialize(election:, notice: nil)
    @election = election
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold election-show", id: dom_id(@election, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing election" }
      
      ElectionPartial(election: @election)
      
      Ui::ResourceActions(resource: @election)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end