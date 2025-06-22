class Views::Topics::TopicPartial < Views::ApplicationView
  def initialize(topic:)
    @topic = topic
  end

  def view_template(&)
    div(id: dom_id(@topic), class: "topic-partial") do
      h3 { @topic.title }
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@topic.description) }
      end
    end
  end
end