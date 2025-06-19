class Views::Registrations::IndexView < Views::ApplicationView
  def initialize(registrations:, notice: nil)
    @registrations = registrations
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold registrations-index", id: "index_registrations") do
      render_notice if @notice.present?
      
      div do
        h1 { "Registrations" }
        link_to "New registration", 
                new_registration_path,
                class: "primary"
      end

      div(id: "registrations") do
        if @registrations.any?
          @registrations.each do |registration|
            div(id: dom_id(registration, :list_item)) do
              Views::Registrations::RegistrationPartial(registration: registration)
              
              div do
                link_to "Show", registration,
                        class: "secondary"
                link_to "Edit", edit_registration_path(registration),
                        class: "secondary"
                button_to "Destroy", registration,
                          method: :delete,
                          class: "danger",
                          data: { turbo_confirm: "Are you sure?" }
              end
            end
          end
        else
          p { "No registrations found." }
        end
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