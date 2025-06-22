class Views::Topics::NewView < Views::ApplicationView
  def initialize(topic:)
    @topic = topic
  end

  def view_template(&)
    div(class: "scaffold topic-new", id: dom_id(@topic, :new)) do
      h1 { "New topic" }
      
      Views::Topics::TopicForm(topic: @topic)
      
      div do
        link_to "Back to topics", 
                topics_path,
                class: "secondary"
      end
    end
  end
end