# frozen_string_literal: true

class Views::Components::FlashMessages < Views::ApplicationView
  ROLES = { notice: "status", alert: "alert" }.freeze

  def view_template
    return unless ROLES.keys.any? { flash[it].present? }

    div(class: "flash-messages") do
      ROLES.each do |kind, role|
        div(class: "flash-#{kind}", role: role) { flash[kind] } if flash[kind].present?
      end
    end
  end
end
