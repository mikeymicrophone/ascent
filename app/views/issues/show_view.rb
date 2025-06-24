class Views::Issues::ShowView < Views::ApplicationView
  def initialize(issue:, notice: nil)
    @issue = issue
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold issue-show", id: dom_id(@issue, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing issue" }
      
      IssuePartial(issue: @issue)
      
      Ui::ResourceActions(resource: @issue)
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end