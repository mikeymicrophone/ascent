# frozen_string_literal: true

# An ECharts chart drawn by the chart Stimulus controller from settings built in Ruby. Rows sets the
# height for charts with a bar per candidate, so a long ballot gets a taller chart.
class Views::Components::Chart < Views::ApplicationView
  prop :options, Hash
  prop :label, String
  prop :rows, _Nilable(Integer)
  prop :modifier, _Nilable(String)

  def view_template
    div(class: [ "chart", ("chart-#{@modifier}" if @modifier) ].compact.join(" "),
      role: "img", aria: { label: @label }, style: ("--chart-rows: #{@rows}" if @rows),
      data: { controller: "chart", chart_options_value: @options.to_json })
  end
end
