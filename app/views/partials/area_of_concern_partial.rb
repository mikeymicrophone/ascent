class Views::Partials::AreaOfConcernPartial < Views::ApplicationView
  def initialize(area_of_concern:)
    @area_of_concern = area_of_concern
  end

  def view_template(&)
    div(id: dom_id(@area_of_concern), class: "area_of_concern-partial") do
      div(class: "partial-header") do
        h3(class: "partial-title") { @area_of_concern.name }
      end

      div(class: "partial-content") do
        if @area_of_concern.description.present?
          div(class: "content-section") do
            div(class: "content-description") { simple_format(@area_of_concern.description) }
          end
        end

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

      expandable(@area_of_concern, :policies) do |policies|
        div(class: "expandable-grid") do
          policies.each do |policy|
            div { helpers.link_to_name(policy) }
          end
        end
      end
    end
  end
end
