class Views::Registrations::ShowView < Views::ApplicationView
  def initialize(registration:, notice: nil)
    @registration = registration
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold registration-show", id: dom_id(@registration, :show)) do
      render_notice if @notice.present?
      
      h1 { "Showing registration" }
      
      Views::Registrations::RegistrationPartial(registration: @registration)
      
      div do
        link_to "Edit this registration", 
                edit_registration_path(@registration),
                class: "secondary"
        link_to "Back to registrations", 
                registrations_path,
                class: "secondary"
        button_to "Destroy this registration", 
                  @registration,
                  method: :delete,
                  class: "danger",
                  data: { turbo_confirm: "Are you sure?" }
      end
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end