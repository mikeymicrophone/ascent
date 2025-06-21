class Views::Issues::NewView < Views::ApplicationView
  def initialize(issue:)
    @issue = issue
  end

  def view_template(&)
    div(class: "scaffold issue-new", id: dom_id(@issue, :new)) do
      h1 { "New issue" }
      
      Views::Issues::IssueForm(issue: @issue)
      
      div do
        link_to "Back to issues", 
                issues_path,
                class: "secondary"
      end
    end
  end
end