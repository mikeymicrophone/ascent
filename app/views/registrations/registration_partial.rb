class Views::Registrations::RegistrationPartial < Views::ApplicationView
  def initialize(registration:)
    @registration = registration
  end

  def view_template(&)
    div(id: dom_id(@registration), class: "registration-partial") do
      h3 { @registration.voter.full_name }
      div do
        span { "Jurisdiction:" }
        whitespace
        link_to @registration.jurisdiction.name, @registration.jurisdiction, class: "link jurisdiction"
      end
      div do
        span { "Registered at:" }
        whitespace
        span { @registration.registered_at.strftime("%B %d, %Y") }
      end
      div do
        span { "Status:" }
        whitespace
        span { @registration.status }
      end
      div do
        span { "Notes:" }
        whitespace
        div(class: "mt-1") { simple_format(@registration.notes) }
      end
    end
  end
end