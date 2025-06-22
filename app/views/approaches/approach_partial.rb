class Views::Approaches::ApproachPartial < Views::ApplicationView
  def initialize(approach:)
    @approach = approach
  end

  def view_template(&)
    div(id: dom_id(@approach), class: "approach-partial") do
      h3 { @approach.title }
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@approach.description) }
      end
      div do
        span { "Issue:" }
        whitespace
        link_to @approach.issue.name, @approach.issue, class: "link issue"
      end
    end
  end
end