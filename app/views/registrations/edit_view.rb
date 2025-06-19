class Views::Registrations::EditView < Views::ApplicationView
  def initialize(registration:)
    @registration = registration
  end

  def view_template(&)
    div(class: "scaffold registration-edit", id: dom_id(@registration, :edit)) do
      h1 { "Editing registration" }
      
      Views::Registrations::RegistrationForm(registration: @registration)
      
      div do
        link_to "Show this registration", 
                @registration,
                class: "secondary"
        link_to "Back to registrations", 
                registrations_path,
                class: "secondary"
      end
    end
  end
end