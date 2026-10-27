# frozen_string_literal: true

# A record's status as a small outlined chip: a race's or election's (upcoming, active, completed, cancelled),
# a candidacy's (announced, active, withdrawn, disqualified), or a law's (pending, enacted, repealed).
# Open and in-force statuses fill with summit; ended ones are struck through.
class Views::Components::StatusChip < Views::ApplicationView
  prop :status, String

  def view_template
    span(class: "race-status-chip race-status-#{@status}") { @status }
  end
end
