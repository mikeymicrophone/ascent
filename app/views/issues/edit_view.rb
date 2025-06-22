class Views::Issues::EditView < Views::ApplicationView
  def initialize(issue:)
    @issue = issue
  end

  def view_template(&)
    div(class: "scaffold issue-edit", id: dom_id(@issue, :edit)) do
      h1 { "Editing issue" }
      
      Views::Issues::IssueForm(issue: @issue)
      
      div do
        link_to "Show this issue", 
                @issue,
                class: "secondary"
        link_to "Back to issues", 
                issues_path,
                class: "secondary"
      end
    end
  end
end