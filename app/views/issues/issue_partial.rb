class Views::Issues::IssuePartial < Views::ApplicationView
  def initialize(issue:)
    @issue = issue
  end

  def view_template(&)
    div(id: dom_id(@issue), class: "issue-partial") do
      h3 { @issue.title }
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@issue.description) }
      end
      div do
        span { "Topic:" }
        whitespace
        link_to @issue.topic.name, @issue.topic, class: "link topic"
      end
    end
  end
end