class Views::Topics::EditView < Views::ApplicationView
  def initialize(topic:)
    @topic = topic
  end

  def view_template(&)
    div(class: "scaffold topic-edit", id: dom_id(@topic, :edit)) do
      h1 { "Editing topic" }
      
      Views::Topics::TopicForm(topic: @topic)
      
      div do
        link_to "Show this topic", 
                @topic,
                class: "secondary"
        link_to "Back to topics", 
                topics_path,
                class: "secondary"
      end
    end
  end
end