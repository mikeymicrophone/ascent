# frozen_string_literal: true

# A race's or election's status as a small outlined chip: upcoming, active, completed, cancelled.
class Views::Components::StatusChip < Views::ApplicationView
  prop :status, String

  def view_template
    span(class: "race-status-chip race-status-#{@status}") { @status }
  end
end
