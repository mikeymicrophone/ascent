class Views::Topics::IndexView < Views::ApplicationView
  def initialize(topics:, pagy: nil, notice: nil)
    @topics = topics
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold topics-index", id: "index_topics") do
      render_notice if @notice.present?
      
      div do
        h1 { "Topics" }
        link_to "New topic", 
                new_topic_path,
                class: "primary"
      end

      div(id: "topics") do
        if @topics.any?
          @topics.each do |topic|
            div(id: dom_id(topic, :list_item)) do
              Views::Topics::TopicPartial(topic: topic)
              
              div do
                link_to "Show", topic,
                        class: "secondary"
                link_to "Edit", edit_topic_path(topic),
                        class: "secondary"
                button_to "Destroy", topic,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No topics found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end