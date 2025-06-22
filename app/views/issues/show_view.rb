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
      
      div do
        link_to "Edit this issue", 
                edit_issue_path(@issue),
                class: "secondary"
        link_to "Back to issues", 
                issues_path,
                class: "secondary"
        button_to "Destroy this issue", 
                  @issue,
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