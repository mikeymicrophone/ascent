class Views::Policies::PolicyPartial < Views::ApplicationView
  def initialize(policy:)
    @policy = policy
  end

  def view_template(&)
    div(id: dom_id(@policy), class: "policy-partial") do
      h3 { @policy.governing_body.name }
      div do
        span { "Area of concern:" }
        whitespace
        link_to @policy.area_of_concern.name, @policy.area_of_concern, class: "link area_of_concern"
      end
      div do
        span { "Approach:" }
        whitespace
        link_to @policy.approach.name, @policy.approach, class: "link approach"
      end
      div do
        span { "Title:" }
        whitespace
        span { @policy.title }
      end
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@policy.description) }
      end
      div do
        span { "Status:" }
        whitespace
        span { @policy.status }
      end
      div do
        span { "Enacted date:" }
        whitespace
        span { @policy.enacted_date }
      end
      div do
        span { "Expiration date:" }
        whitespace
        span { @policy.expiration_date }
      end
    end
  end
end
