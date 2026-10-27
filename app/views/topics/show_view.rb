class Views::Topics::ShowView < Views::ApplicationView
  prop :topic, Topic

  def view_template
    ResourceShow(record: @topic) do
      TopicPartial(topic: @topic)

      issues_section if @topic.issues.any?
      stances_section if @topic.stances.any?
    end
  end

  private

  def issues_section
    content_section "Issues in this Topic", key: "issues" do
      @topic.issues.each { IssuePartial(issue: it, show_topic: false, show_approaches: true) }
    end
  end

  def stances_section
    content_section "Candidate Positions on this Topic", key: "stances" do
      @topic.stances.includes(:candidacy, :issue, :approach).each do |stance|
        StancePartial(stance: stance, show_candidacy: true, show_issue: true, show_approach: true)
      end
    end
  end

  def content_section(title, key:, &)
    div(class: "topic-content-section topic-#{key}") do
      h2 { title }
      yield
    end
  end
end
