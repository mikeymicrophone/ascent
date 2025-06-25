class Views::Partials::GovernanceTypePartial < Views::ApplicationView
  def initialize(governance_type:)
    @governance_type = governance_type
  end

  def view_template(&)
    div(id: dom_id(@governance_type), class: "governance_type-partial") do
      # Header
      div(class: "partial-header") do
        h3(class: "partial-title") { @governance_type.name }
      end

      # Hierarchical navigation (improved positioning)
      div(class: "navigation-section") do
        HierarchicalNavigation(current_object: @governance_type)
      end

      # Main content
      div(class: "partial-content") do
        # Description
        if @governance_type.description.present?
          div(class: "content-section") do
            div(class: "content-description") { simple_format(@governance_type.description) }
          end
        end
        
        # Governance information grid
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Authority Level" }
            span(class: "info-value") { @governance_type.authority_level }
          end
          div(class: "info-item") do
            span(class: "info-label") { "Decision Making Process" }
            span(class: "info-value") { @governance_type.decision_making_process }
          end
        end
      end
    end
  end
end