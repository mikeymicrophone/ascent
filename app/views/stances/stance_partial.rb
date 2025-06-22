class Views::Stances::StancePartial < Views::ApplicationView
  def initialize(stance:, show_candidacy: true, show_issue: true, show_approach: true)
    @stance = stance
    @show_candidacy = show_candidacy
    @show_issue = show_issue
    @show_approach = show_approach
  end

  def view_template(&)
    div(id: dom_id(@stance), class: "stance-partial") do
      if @show_candidacy
        h3 do
          link_to @stance.candidacy.person.full_name, @stance.candidacy, class: "link candidacy"
          span(class: "stance-priority stance-priority-#{@stance.priority_level}") { " (#{@stance.priority_level} priority)" }
        end
      end
      
      if @show_issue
        div do
          span { "Issue:" }
          whitespace
          link_to @stance.issue.title, @stance.issue, class: "link issue"
        end
      end
      
      if @show_approach
        div do
          span { "Approach:" }
          whitespace
          link_to @stance.approach.title, @stance.approach, class: "link approach"
        end
      end
      
      if @stance.explanation.present?
        div do
          span { "Explanation:" }
          whitespace
          div(class: "mt-1") { simple_format(@stance.explanation) }
        end
      end
      
      unless @show_candidacy
        div do
          span { "Priority level:" }
          whitespace
          span(class: "stance-priority stance-priority-#{@stance.priority_level}") { @stance.priority_level.capitalize }
        end
      end
      
      if @stance.evidence_links.present?
        div do
          span { "Evidence links:" }
          whitespace
          div(class: "mt-1") { simple_format(@stance.evidence_links) }
        end
      end
    end
  end
end