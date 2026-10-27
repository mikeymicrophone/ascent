# frozen_string_literal: true

# One headline number with what it counts, as in the results and place summaries. A whole number counts up
# from zero the first time it scrolls into view; dates, shares and decimals simply appear.
class Views::Components::StatTile < Views::ApplicationView
  WHOLE_NUMBER = /\A\d{1,3}(,\d{3})*\z/

  prop :value, String
  prop :label, String
  prop :modifier, _Nilable(String)

  def view_template
    div(class: [ "stat-tile", ("stat-tile-#{@modifier}" if @modifier) ].compact.join(" ")) do
      span(class: "stat-tile-value", data: count_up) { @value }
      span(class: "stat-tile-label") { @label }
    end
  end

  private

  def count_up
    { controller: "count-up", count_up_target_value: @value.delete(",").to_i } if @value.match?(WHOLE_NUMBER) && @value != "0"
  end
end
