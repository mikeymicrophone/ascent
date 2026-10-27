class Views::Topics::TopicForm < Views::Components::Forms::Base
  def view_template
    row field(:title).text
    row field(:description).textarea(rows: 4)
  end
end
