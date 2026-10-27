class Views::Topics::NewView < Views::ApplicationView
  prop :topic, Topic

  def view_template
    ResourceFormPage(record: @topic) { render Views::Topics::TopicForm.new(@topic) }
  end
end
