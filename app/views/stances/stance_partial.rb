class Views::Stances::StancePartial < Views::ApplicationView
  def initialize(stance:)
    @stance = stance
  end

  def view_template(&)
    div(id: dom_id(@stance), class: "stance-partial") do
      h3 { @stance.candidacy_id }
      div do
        span { "Issue:" }
        whitespace
        link_to @stance.issue.name, @stance.issue, class: "link issue"
      end
      div do
        span { "Approach:" }
        whitespace
        link_to @stance.approach.name, @stance.approach, class: "link approach"
      end
      div do
        span { "Explanation:" }
        whitespace
        div(class: "mt-1") { simple_format(@stance.explanation) }
      end
      div do
        span { "Priority level:" }
        whitespace
        span { @stance.priority_level }
      end
      div do
        span { "Evidence links:" }
        whitespace
        div(class: "mt-1") { simple_format(@stance.evidence_links) }
      end
    end
  end
end