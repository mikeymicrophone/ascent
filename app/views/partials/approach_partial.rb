class Views::Partials::ApproachPartial < Views::ApplicationView
  def initialize(approach:)
    @approach = approach
  end

  def view_template(&)
    div(id: dom_id(@approach), class: "approach-partial") do
      h3 { @approach.title }

      HierarchicalNavigation(current_object: @approach)

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
      
      expandable(@approach, :stances, title: "Candidate Positions") do |stances|
        stances.each { StancePartial(stance: it, show_candidacy: true, show_issue: false, show_approach: false) }
      end
    end
  end
end