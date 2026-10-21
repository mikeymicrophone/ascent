class Views::Partials::ResidencePartial < Views::ApplicationView
  def initialize(residence:)
    @residence = residence
  end

  def view_template(&)
    div(id: dom_id(@residence), class: "residence-partial") do
      h3 { @residence.voter.full_name }
      div do
        span { "Jurisdiction:" }
        whitespace
        jurisdiction_link @residence.jurisdiction
      end
      div do
        span { "Registered at:" }
        whitespace
        span { @residence.registered_at.to_fs(:display) }
      end
      div do
        span { "Status:" }
        whitespace
        span { @residence.status }
      end
      div do
        span { "Notes:" }
        whitespace
        div(class: "formatted-text") { simple_format(@residence.notes) }
      end
    end
  end
end