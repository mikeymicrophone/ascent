class Views::Issues::IssueForm < Views::Components::Forms::Base
  def view_template
    row field(:title).text
    row field(:description).textarea(rows: 4)
    row field(:topic_id).collection_select(::Topic.all, text: :name, prompt: "Select a topic"), label: "Topic"
  end
end
