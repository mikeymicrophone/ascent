# frozen_string_literal: true

# One headline number with what it counts, as in the results and place summaries.
class Views::Components::StatTile < Views::ApplicationView
  prop :value, String
  prop :label, String
  prop :modifier, _Nilable(String)

  def view_template
    div(class: [ "stat-tile", ("stat-tile-#{@modifier}" if @modifier) ].compact.join(" ")) do
      span(class: "stat-tile-value") { @value }
      span(class: "stat-tile-label") { @label }
    end
  end
end
