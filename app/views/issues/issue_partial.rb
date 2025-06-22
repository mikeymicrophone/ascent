class Views::Issues::IssuePartial < Views::ApplicationView
  def initialize(issue:, show_topic: true, show_approaches: false)
    @issue = issue
    @show_topic = show_topic
    @show_approaches = show_approaches
  end

  def view_template(&)
    div(id: dom_id(@issue), class: "issue-partial") do
      h3 { @issue.title }
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@issue.description) }
      end
      
      if @show_topic
        div do
          span { "Topic:" }
          whitespace
          link_to @issue.topic.title, @issue.topic, class: "link topic"
        end
      end
      
      if @show_approaches && @issue.approaches.any?
        div(class: "issue-approaches") do
          span { "Available Approaches:" }
          ul do
            @issue.approaches.each do |approach|
              li do
                link_to approach.title, approach, class: "link approach"
              end
            end
          end
        end
      end
    end
  end
end