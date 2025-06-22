class Views::Candidacies::CandidateStancePartial < Views::ApplicationView
  def initialize(stance:)
    @stance = stance
  end

  def view_template(&)
    div(class: "candidate-stance") do
      div(class: "stance-header") do
        h5(class: "stance-issue-title") do
          link_to @stance.issue.title, @stance.issue, class: "stance-issue-link"
        end
        span(class: "stance-priority-badge stance-priority-#{@stance.priority_level}") { @stance.priority_level.capitalize }
      end
      
      div(class: "stance-approach") do
        span(class: "stance-label") { "Supports: " }
        link_to @stance.approach.title, @stance.approach, class: "stance-approach-link"
      end
      
      if @stance.explanation.present?
        div(class: "stance-explanation") do
          p(class: "stance-explanation-text") { @stance.explanation }
        end
      end
      
      if @stance.evidence_links.present?
        div(class: "stance-evidence") do
          span(class: "stance-label") { "Evidence: " }
          span(class: "stance-evidence-links") { @stance.evidence_links }
        end
      end
    end
  end
end