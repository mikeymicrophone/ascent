class Views::Issues::ShowView < Views::ApplicationView
  prop :issue, Issue

  def view_template
    ResourceShow(record: @issue) { IssuePartial(issue: @issue) }
  end
end
