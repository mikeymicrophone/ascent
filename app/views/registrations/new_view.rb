class Views::Registrations::NewView < Views::ApplicationView
  def initialize(registration:)
    @registration = registration
  end

  def view_template(&)
    div(class: "scaffold registration-new", id: dom_id(@registration, :new)) do
      h1 { "New registration" }
      
      Views::Registrations::RegistrationForm(registration: @registration)
      
      div do
        link_to "Back to registrations", 
                registrations_path,
                class: "secondary"
      end
    end
  end
end