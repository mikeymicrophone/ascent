class Views::Partials::PolicyPartial < Views::ApplicationView
  def initialize(policy:)
    @policy = policy
  end

  def view_template(&)
    div(id: dom_id(@policy), class: "policy-partial") do
      h3 { @policy.governing_body.name }

      HierarchicalNavigation(current_object: @policy)

      h4 { @policy.title } unless helpers.controller_name == "policies"
      div do
        span { "Area of concern:" }
        whitespace
        link_to @policy.area_of_concern.name, @policy.area_of_concern, class: "link area_of_concern"
      end
      div do
        helpers.link_to_name @policy.approach, class: "link approach"
      end
      div do
        div(class: "mt-1") { simple_format(@policy.description) }
      end
      div do
        span { "Status:" }
        whitespace
        span { @policy.status }
      end
      div do
        span { "Enacted date:" }
        span { @policy.enacted_date }
        span { "-" }
        span { @policy.expiration_date }
      end
    end
  end
end
