class Views::Partials::GovernanceTypePartial < Views::ApplicationView
  def initialize(governance_type:)
    @governance_type = governance_type
  end

  def view_template(&)
    div(id: dom_id(@governance_type), class: "governance_type-partial") do
      h3 { @governance_type.name }
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@governance_type.description) }
      end
      div do
        span { "Authority level:" }
        whitespace
        span { @governance_type.authority_level }
      end
      div do
        span { "Decision making process:" }
        whitespace
        span { @governance_type.decision_making_process }
      end
    end
  end
end