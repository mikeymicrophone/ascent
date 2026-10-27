class Views::Issues::NewView < Views::ApplicationView
  prop :issue, Issue

  def view_template
    ResourceFormPage(record: @issue) { render Views::Issues::IssueForm.new(@issue) }
  end
end
