class Views::Topics::ShowView < Views::ApplicationView
  def initialize(topic:, notice: nil)
    @topic = topic
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold topic-show", id: dom_id(@topic, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing topic" }
      
      Views::Topics::TopicPartial(topic: @topic)
      
      div do
        link_to "Edit this topic", 
                edit_topic_path(@topic),
                class: "secondary"
        link_to "Back to topics", 
                topics_path,
                class: "secondary"
        button_to "Destroy this topic", 
                  @topic,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end