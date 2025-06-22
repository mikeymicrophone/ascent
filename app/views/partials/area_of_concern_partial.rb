class Views::Partials::AreaOfConcernPartial < Views::ApplicationView
  def initialize(area_of_concern:)
    @area_of_concern = area_of_concern
  end

  def view_template(&)
    div(id: dom_id(@area_of_concern), class: "area_of_concern-partial") do
      h3 { @area_of_concern.name }
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@area_of_concern.description) }
      end
      div do
        span { "Policy domain:" }
        whitespace
        span { @area_of_concern.policy_domain }
      end
      div do
        span { "Regulatory scope:" }
        whitespace
        span { @area_of_concern.regulatory_scope }
      end
    end
  end
end