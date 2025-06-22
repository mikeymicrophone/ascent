class Views::Partials::TopicPartial < Views::ApplicationView
  def initialize(topic:)
    @topic = topic
  end

  def view_template(&)
    div(id: dom_id(@topic), class: "topic-partial") do
      h3 { @topic.title }

      HierarchicalNavigation(current_object: @topic)

      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@topic.description) }
      end
      
      expandable(@topic, :issues) do |issues|
        issues.each { IssuePartial(issue: it, show_topic: false, show_approaches: true) }
      end
    end
  end
end