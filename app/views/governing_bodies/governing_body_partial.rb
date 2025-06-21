class Views::GoverningBodies::GoverningBodyPartial < Views::ApplicationView
  def initialize(governing_body:)
    @governing_body = governing_body
  end

  def view_template(&)
    div(id: dom_id(@governing_body), class: "governing_body-partial") do
      h3 { @governing_body.name }
      div do
        span { "Jurisdiction type:" }
        whitespace
        span { @governing_body.jurisdiction_type }
      end
      div do
        span { "Jurisdiction:" }
        whitespace
        link_to @governing_body.jurisdiction.name, @governing_body.jurisdiction, class: "link jurisdiction"
      end
      div do
        span { "Governance type:" }
        whitespace
        link_to @governing_body.governance_type.name, @governing_body.governance_type, class: "link governance_type"
      end
      div do
        span { "Description:" }
        whitespace
        div(class: "mt-1") { simple_format(@governing_body.description) }
      end
      div do
        span { "Meeting schedule:" }
        whitespace
        span { @governing_body.meeting_schedule }
      end
      div do
        span { "Is active:" }
        whitespace
        span { @governing_body.is_active }
      end
      div do
        span { "Established date:" }
        whitespace
        span { @governing_body.established_date }
      end
    end
  end
end