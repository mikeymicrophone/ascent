class Views::Issues::ShowView < Views::ApplicationView
  def initialize(issue:)
    @issue = issue
  end

  def view_template(&)
    div(class: "scaffold issue-show", id: dom_id(@issue, :show)) do
      h1 { "Showing issue" }

      IssuePartial(issue: @issue)

      Ui::ResourceActions(resource: @issue)
    end
  end
end
