class Views::Partials::AreaOfConcernPartial < Views::ApplicationView
  def initialize(area_of_concern:)
    @area_of_concern = area_of_concern
  end

  def view_template(&)
    div(id: dom_id(@area_of_concern), class: "area_of_concern-partial") do
      # Header
      div(class: "partial-header") do
        h3(class: "partial-title") { @area_of_concern.name }
      end
      
      # Main content
      div(class: "partial-content") do
        # Description
        if @area_of_concern.description.present?
          div(class: "content-section") do
            div(class: "content-description") { simple_format(@area_of_concern.description) }
          end
        end
        
        # Policy information grid
        div(class: "info-grid") do
          div(class: "info-item") do
            span(class: "info-label") { "Policy Domain" }
            span(class: "info-value") { @area_of_concern.policy_domain }
          end
          div(class: "info-item") do
            span(class: "info-label") { "Regulatory Scope" }
            span(class: "info-value") { @area_of_concern.regulatory_scope }
          end
        end
      end
    end
  end
end