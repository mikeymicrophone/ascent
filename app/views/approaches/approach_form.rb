class Views::Approaches::ApproachForm < Views::Components::Forms::Base
  def view_template
    row field(:title).text
    row field(:description).textarea(rows: 4)
    row field(:issue_id).collection_select(::Issue.all, text: :name, prompt: "Select an issue"), label: "Issue"
  end
end
