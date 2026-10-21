class Views::Topics::ShowView < Views::ApplicationView
  def initialize(topic:)
    @topic = topic
    @content_sections = []
  end

  def view_template(&block)
    if block
      yield(self)
    else
      render_default_content
    end

    div(class: "scaffold topic-show", id: dom_id(@topic, :show)) do
      h1 { "Showing topic" }

      TopicPartial(topic: @topic)

      @content_sections.each do |section|
        div(class: "topic-content-section topic-#{section[:key]}") do
          h2 { section[:title] }
          section[:content].call
        end
      end

      Ui::ResourceActions(resource: @topic)
    end
  end

  def content_section(title, key: nil, &block)
    section_key = key || title.downcase.gsub(/\s+/, '-')
    @content_sections << {
      key: section_key,
      title: title,
      content: block
    }
  end

  private

  def render_default_content
    if @topic.issues.any?
      content_section("Issues in this Topic", key: "issues") do
        @topic.issues.each do |issue|
          IssuePartial(issue: issue, show_topic: false, show_approaches: true)
        end
      end
    end

    if @topic.stances.any?
      content_section("Candidate Positions on this Topic", key: "stances") do
        @topic.stances.includes(:candidacy, :issue, :approach).each do |stance|
          StancePartial(stance: stance, show_candidacy: true, show_issue: true, show_approach: true)
        end
      end
    end
  end
end
